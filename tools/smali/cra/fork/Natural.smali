.class public final Lcra/fork/Natural;
.super Ljava/lang/Object;
.source "Natural.smali"

# Natural ("numeric") string order, case-insensitive, as in ComicRack CE 0.9.180+
# ("Updated default sort to be natural sorting"): "page 2" < "page 10".
# Digit runs compare by value (leading zeros ignored), other characters by
# Character.toLowerCase. Ties fall back to String.compareToIgnoreCase.
#
# Java equivalent:
#   int i = 0, j = 0, na = a.length(), nb = b.length();
#   while (i < na && j < nb) {
#     char ca = a.charAt(i), cb = b.charAt(j);
#     if (isDigit(ca) && isDigit(cb)) {
#       int si = i; while (si < na && a.charAt(si) == '0') si++;
#       int sj = j; while (sj < nb && b.charAt(sj) == '0') sj++;
#       int ei = si; while (ei < na && isDigit(a.charAt(ei))) ei++;
#       int ej = sj; while (ej < nb && isDigit(b.charAt(ej))) ej++;
#       if (ei - si != ej - sj) return (ei - si) - (ej - sj);
#       for (; si < ei; si++, sj++) if (a.charAt(si) != b.charAt(sj)) return a.charAt(si) - b.charAt(sj);
#       i = ei; j = ej;
#     } else {
#       ca = toLowerCase(ca); cb = toLowerCase(cb);
#       if (ca != cb) return ca - cb;
#       i++; j++;
#     }
#   }
#   int r = (na - i) - (nb - j);
#   return r != 0 ? r : a.compareToIgnoreCase(b);

.method public static compare(Ljava/lang/String;Ljava/lang/String;)I
    .locals 12

    # v0=i v1=j v2=na v3=nb v4=ca v5=cb v6..v11 temps
    const/4 v0, 0x0

    const/4 v1, 0x0

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v2

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v3

    :loop
    if-ge v0, v2, :done

    if-ge v1, v3, :done

    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    move-result v4

    invoke-virtual {p1, v1}, Ljava/lang/String;->charAt(I)C

    move-result v5

    invoke-static {v4}, Ljava/lang/Character;->isDigit(C)Z

    move-result v6

    if-eqz v6, :text

    invoke-static {v5}, Ljava/lang/Character;->isDigit(C)Z

    move-result v6

    if-eqz v6, :text

    # skip leading zeros: v6 = si, v7 = sj
    move v6, v0

    :zero_a
    if-ge v6, v2, :zero_a_end

    invoke-virtual {p0, v6}, Ljava/lang/String;->charAt(I)C

    move-result v8

    const/16 v9, 0x30

    if-ne v8, v9, :zero_a_end

    add-int/lit8 v6, v6, 0x1

    goto :zero_a

    :zero_a_end
    move v7, v1

    :zero_b
    if-ge v7, v3, :zero_b_end

    invoke-virtual {p1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v8

    const/16 v9, 0x30

    if-ne v8, v9, :zero_b_end

    add-int/lit8 v7, v7, 0x1

    goto :zero_b

    # end of digit runs: v8 = ei, v9 = ej
    :zero_b_end
    move v8, v6

    :end_a
    if-ge v8, v2, :end_a_done

    invoke-virtual {p0, v8}, Ljava/lang/String;->charAt(I)C

    move-result v10

    invoke-static {v10}, Ljava/lang/Character;->isDigit(C)Z

    move-result v10

    if-eqz v10, :end_a_done

    add-int/lit8 v8, v8, 0x1

    goto :end_a

    :end_a_done
    move v9, v7

    :end_b
    if-ge v9, v3, :end_b_done

    invoke-virtual {p1, v9}, Ljava/lang/String;->charAt(I)C

    move-result v10

    invoke-static {v10}, Ljava/lang/Character;->isDigit(C)Z

    move-result v10

    if-eqz v10, :end_b_done

    add-int/lit8 v9, v9, 0x1

    goto :end_b

    # different number of significant digits: the shorter is smaller
    :end_b_done
    sub-int v10, v8, v6

    sub-int v11, v9, v7

    if-eq v10, v11, :same_len

    sub-int v10, v10, v11

    return v10

    # same length: compare digit by digit
    :same_len
    if-ge v6, v8, :number_equal

    invoke-virtual {p0, v6}, Ljava/lang/String;->charAt(I)C

    move-result v10

    invoke-virtual {p1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v11

    if-eq v10, v11, :next_digit

    sub-int v10, v10, v11

    return v10

    :next_digit
    add-int/lit8 v6, v6, 0x1

    add-int/lit8 v7, v7, 0x1

    goto :same_len

    :number_equal
    move v0, v8

    move v1, v9

    goto :loop

    :text
    invoke-static {v4}, Ljava/lang/Character;->toLowerCase(C)C

    move-result v4

    invoke-static {v5}, Ljava/lang/Character;->toLowerCase(C)C

    move-result v5

    if-eq v4, v5, :next_char

    sub-int v4, v4, v5

    return v4

    :next_char
    add-int/lit8 v0, v0, 0x1

    add-int/lit8 v1, v1, 0x1

    goto :loop

    :done
    sub-int v6, v2, v0

    sub-int v7, v3, v1

    sub-int v6, v6, v7

    if-nez v6, :result

    invoke-virtual {p0, p1}, Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I

    move-result v6

    :result
    return v6
.end method
