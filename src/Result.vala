public class Result {
    public string location;
    public string name;
    public string type;

    public Result.null () {
        location = "";
        name = "";
        type = "";
    }

    public Result (string _location, string _name, string _type) {
        location = _location;
        name = _name;

        if (_type != "") {
            type = _type;
        } else {
            type = "Executable";
        }
    }
}
