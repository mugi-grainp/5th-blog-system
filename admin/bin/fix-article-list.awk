BEGIN {
    FS = "/"
    OFS = "\t"
}

{
    split($NF, directory, "-")
    d = gensub(/([0-9]{4})([0-9]{2})([0-9]{2})/, "\\1.\\2.\\3", "g", directory[1])

    print d, $NF
}
