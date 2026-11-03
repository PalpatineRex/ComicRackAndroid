#!/usr/bin/env python3
"""Sign an APK with a v1 (JAR) signature, pure Python (no JDK needed).

Needs the 'cryptography' package:  pip install cryptography

  sign_v1.py gen-test-key  KEY.pem CERT.pem          create a throwaway test key
  sign_v1.py sign IN.apk OUT.apk KEY.pem CERT.pem    sign (IN may be signed; old signature is dropped)

v1 only: fine for apps with targetSdk < 30. For releases CI uses tools/sign.sh (jarsigner).
Never commit key files (.gitignore blocks *.pem).
"""
import base64
import datetime
import hashlib
import sys
import zipfile

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs7
from cryptography.x509.oid import NameOID

CREATED_BY = "ComicRackAndroid tools (sign_v1.py)"


def b64(data: bytes) -> str:
    return base64.b64encode(data).decode("ascii")


def wrap(line: str) -> bytes:
    """JAR manifest rule: lines are at most 72 bytes; continuations start with a space."""
    raw = line.encode("utf-8")
    out, first = [], True
    while raw:
        limit = 72 if first else 71
        out.append((b"" if first else b" ") + raw[:limit])
        raw = raw[limit:]
        first = False
    return b"\r\n".join(out) + b"\r\n"


def is_signature_file(name: str) -> bool:
    return name == "META-INF/MANIFEST.MF" or (
        name.startswith("META-INF/") and name.endswith((".SF", ".RSA", ".DSA", ".EC"))
    )


def gen_test_key(key_path: str, cert_path: str) -> None:
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "ComicRackAndroid TEST")])
    now = datetime.datetime.now(datetime.timezone.utc)
    cert = (
        x509.CertificateBuilder()
        .subject_name(name).issuer_name(name).public_key(key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now).not_valid_after(now + datetime.timedelta(days=10000))
        .sign(key, hashes.SHA256())
    )
    with open(key_path, "wb") as f:
        f.write(key.private_bytes(serialization.Encoding.PEM,
                                  serialization.PrivateFormat.PKCS8,
                                  serialization.NoEncryption()))
    with open(cert_path, "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    print("wrote", key_path, cert_path)


def sign(src: str, dst: str, key_path: str, cert_path: str) -> None:
    key = serialization.load_pem_private_key(open(key_path, "rb").read(), password=None)
    cert = x509.load_pem_x509_certificate(open(cert_path, "rb").read())

    with zipfile.ZipFile(src) as zin:
        infos = [i for i in zin.infolist()
                 if not i.is_dir() and not is_signature_file(i.filename)]
        datas = {i.filename: zin.read(i.filename) for i in infos}

        manifest_main = wrap("Manifest-Version: 1.0") + wrap("Created-By: " + CREATED_BY) + b"\r\n"
        sections = {}
        for i in infos:
            sec = wrap("Name: " + i.filename) \
                + wrap("SHA-256-Digest: " + b64(hashlib.sha256(datas[i.filename]).digest())) \
                + b"\r\n"
            sections[i.filename] = sec
        manifest = manifest_main + b"".join(sections[i.filename] for i in infos)

        sf = wrap("Signature-Version: 1.0") + wrap("Created-By: " + CREATED_BY) \
            + wrap("SHA-256-Digest-Manifest: " + b64(hashlib.sha256(manifest).digest())) + b"\r\n"
        for i in infos:
            sf += wrap("Name: " + i.filename) \
                + wrap("SHA-256-Digest: " + b64(hashlib.sha256(sections[i.filename]).digest())) \
                + b"\r\n"

        rsa_sig = (
            pkcs7.PKCS7SignatureBuilder()
            .set_data(sf)
            .add_signer(cert, key, hashes.SHA256())
            .sign(serialization.Encoding.DER,
                  [pkcs7.PKCS7Options.DetachedSignature, pkcs7.PKCS7Options.NoCapabilities])
        )

        with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
            for name, data in (("META-INF/MANIFEST.MF", manifest),
                               ("META-INF/CERT.SF", sf),
                               ("META-INF/CERT.RSA", rsa_sig)):
                zout.writestr(zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0)), data,
                              compress_type=zipfile.ZIP_DEFLATED)
            for i in infos:
                zi = zipfile.ZipInfo(i.filename, date_time=i.date_time)
                zi.compress_type = i.compress_type
                zi.external_attr = i.external_attr
                zout.writestr(zi, datas[i.filename])
    print("signed", dst)


def main() -> None:
    a = sys.argv[1:]
    if len(a) == 3 and a[0] == "gen-test-key":
        gen_test_key(a[1], a[2])
    elif len(a) == 5 and a[0] == "sign":
        sign(*a[1:])
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
