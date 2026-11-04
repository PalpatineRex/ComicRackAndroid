package cra.fork;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import javax.xml.parsers.DocumentBuilderFactory;

/**
 * Extra metadata files inside comic archives (ComicRack CE): ComicBook.xml (a superset of
 * ComicInfo.xml) and MetronInfo.xml are turned into ComicInfo.xml content for the app's own parser.
 */
public final class Meta {
    private Meta() {}

    /** Fallback when the archive has no ComicInfo.xml: ComicBook.xml, then MetronInfo.xml. */
    public static ZipEntry pick(ZipFile z) {
        try {
            ZipEntry book = null;
            ZipEntry metron = null;
            Enumeration<? extends ZipEntry> en = z.entries();
            while (en.hasMoreElements()) {
                ZipEntry e = en.nextElement();
                String n = e.getName();
                if (n.equalsIgnoreCase("ComicBook.xml")) book = e;
                else if (n.equalsIgnoreCase("MetronInfo.xml")) metron = e;
            }
            return book != null ? book : metron;
        } catch (Throwable t) {
            return null;
        }
    }

    /** Returns a ComicInfo-shaped stream; unknown or broken input comes back unchanged. */
    public static InputStream convert(InputStream in) {
        byte[] raw;
        try {
            ByteArrayOutputStream bo = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0 && bo.size() < (4 << 20)) bo.write(buf, 0, n);
            raw = bo.toByteArray();
            in.close();
        } catch (Throwable t) {
            return in;
        }
        try {
            Document d = DocumentBuilderFactory.newInstance().newDocumentBuilder()
                    .parse(new ByteArrayInputStream(raw));
            Element root = d.getDocumentElement();
            String name = root.getNodeName();
            if (name.equals("MetronInfo")) return new ByteArrayInputStream(fromMetron(root).getBytes("UTF-8"));
            if (name.equals("ComicBook")) return new ByteArrayInputStream(rename(root).getBytes("UTF-8"));
        } catch (Throwable t) {
            // not parseable here: let the app's parser decide
        }
        return new ByteArrayInputStream(raw);
    }

    // ComicBook.xml: same element names as ComicInfo.xml, plus library-only fields.
    private static String rename(Element root) {
        StringBuilder sb = new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?><ComicInfo>");
        for (Node c = root.getFirstChild(); c != null; c = c.getNextSibling()) {
            if (c.getNodeType() != Node.ELEMENT_NODE) continue;
            String n = c.getNodeName();
            if (OWN.contains(" " + n + " ")) continue; // library state, not metadata
            sb.append(serialize((Element) c));
        }
        return sb.append("</ComicInfo>").toString();
    }

    private static final String OWN = " File Id Checked Pages ";

    private static String serialize(Element e) {
        StringBuilder sb = new StringBuilder("<").append(e.getNodeName()).append('>');
        for (Node c = e.getFirstChild(); c != null; c = c.getNextSibling()) {
            if (c.getNodeType() == Node.ELEMENT_NODE) sb.append(serialize((Element) c));
            else if (c.getNodeType() == Node.TEXT_NODE || c.getNodeType() == Node.CDATA_SECTION_NODE)
                sb.append(esc(c.getNodeValue()));
        }
        return sb.append("</").append(e.getNodeName()).append('>').toString();
    }

    private static String esc(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private static Element child(Element p, String name) {
        if (p == null) return null;
        for (Node c = p.getFirstChild(); c != null; c = c.getNextSibling())
            if (c.getNodeType() == Node.ELEMENT_NODE && c.getNodeName().equals(name)) return (Element) c;
        return null;
    }

    private static String text(Element p, String name) {
        Element e = child(p, name);
        return e == null ? "" : e.getTextContent().trim();
    }

    private static List<Element> kids(Element p, String name) {
        List<Element> l = new ArrayList<Element>();
        if (p == null) return l;
        NodeList nl = p.getChildNodes();
        for (int i = 0; i < nl.getLength(); i++) {
            Node c = nl.item(i);
            if (c.getNodeType() == Node.ELEMENT_NODE && c.getNodeName().equals(name)) l.add((Element) c);
        }
        return l;
    }

    private static String join(List<Element> l) {
        StringBuilder sb = new StringBuilder();
        for (Element e : l) {
            String t = e.getTextContent().trim();
            if (t.length() == 0) continue;
            if (sb.length() > 0) sb.append(", ");
            sb.append(t);
        }
        return sb.toString();
    }

    private static void put(StringBuilder sb, String tag, String v) {
        if (v != null && v.length() > 0) sb.append('<').append(tag).append('>').append(esc(v)).append("</").append(tag).append('>');
    }

    private static String credits(Element root, String... wanted) {
        StringBuilder sb = new StringBuilder();
        for (Element cr : kids(child(root, "Credits"), "Credit")) {
            String who = text(cr, "Creator");
            for (Element r : kids(child(cr, "Roles"), "Role")) {
                String role = r.getTextContent().trim();
                for (String w : wanted) {
                    if (role.equals(w) || (w.startsWith("~") && role.contains(w.substring(1)))) {
                        if (sb.length() > 0) sb.append(", ");
                        sb.append(who);
                        break;
                    }
                }
            }
        }
        return sb.toString();
    }

    // Mapping follows ComicRack CE's MetronInfoProvider.
    private static String fromMetron(Element m) {
        StringBuilder sb = new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?><ComicInfo>");
        Element pub = child(m, "Publisher");
        put(sb, "Publisher", text(pub, "Name"));
        put(sb, "Imprint", text(pub, "Imprint"));
        put(sb, "Writer", credits(m, "Writer", "Plot"));
        put(sb, "Penciller", credits(m, "Penciller"));
        put(sb, "Inker", credits(m, "Inker", "Ink Assists"));
        put(sb, "Colorist", credits(m, "~Color"));
        put(sb, "Editor", credits(m, "~Editor"));
        put(sb, "Letterer", credits(m, "Letterer"));
        put(sb, "CoverArtist", credits(m, "Cover"));
        Element series = child(m, "Series");
        put(sb, "Series", text(series, "Name"));
        put(sb, "Number", text(m, "Number"));
        put(sb, "Count", text(series, "IssueCount"));
        String vol = text(series, "Volume");
        put(sb, "Volume", vol.length() > 0 ? vol : text(series, "StartYear"));
        put(sb, "LanguageISO", series != null && series.getAttribute("lang").length() > 0
                ? series.getAttribute("lang") : text(series, "Lang"));
        put(sb, "Format", text(series, "Format"));
        List<Element> stories = kids(child(m, "Stories"), "Story");
        if (stories.size() > 0) put(sb, "Title", stories.get(0).getTextContent().trim());
        if (stories.size() > 1) put(sb, "StoryArc", stories.get(1).getTextContent().trim());
        List<Element> arcs = kids(child(m, "Arcs"), "Arc");
        if (arcs.size() > 0) {
            put(sb, "AlternateSeries", text(arcs.get(0), "Name"));
            put(sb, "AlternateNumber", text(arcs.get(0), "Number"));
        }
        put(sb, "Summary", text(m, "Summary"));
        put(sb, "Notes", text(m, "Notes"));
        String cd = text(m, "CoverDate");
        if (cd.length() >= 4) {
            String[] p = cd.split("-");
            put(sb, "Year", p[0]);
            if (p.length > 1) put(sb, "Month", String.valueOf(parse(p[1])));
            if (p.length > 2) put(sb, "Day", String.valueOf(parse(p[2])));
        }
        put(sb, "Genre", join(kids(child(m, "Genres"), "Genre")));
        put(sb, "Characters", join(kids(child(m, "Characters"), "Character")));
        put(sb, "Teams", join(kids(child(m, "Teams"), "Team")));
        put(sb, "Locations", join(kids(child(m, "Locations"), "Location")));
        put(sb, "Tags", join(kids(child(m, "Tags"), "Tag")));
        String web = "";
        for (Element u : kids(child(m, "URLs"), "URL")) {
            if (web.length() == 0 || "true".equalsIgnoreCase(u.getAttribute("primary"))) web = u.getTextContent().trim();
        }
        put(sb, "Web", web);
        put(sb, "PageCount", text(m, "PageCount"));
        put(sb, "AgeRating", text(m, "AgeRating"));
        return sb.append("</ComicInfo>").toString();
    }

    private static int parse(String s) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return 0;
        }
    }
}
