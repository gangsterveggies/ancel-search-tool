void main () {
    List<Result> rr = SearchTool.search_keyword ("~/", "*.c");

    foreach (Result r in rr) {
        print (r.location + "\n");
    }
}