/***
    BEGIN LICENSE

    Copyright (C) 2013 Pedro Paredes <gangsterveggies@gmail.com>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>

    END LICENSE
***/

using Posix;

public class Result {
    public string location;
    public string name;

    public Result (string _location, string _name) {
        location = _location;
        name = _name;
    }
}

public class SearchTool {

    public static Result parseLocation (string loc) {
        string name = "";

        for (int i = loc.length - 1; i >= 0; i--) {
            name += loc[i].to_string ();
        }

        return new Result (loc, name);
    }

    public static List<Result> search_keyword (string location, string keyword) {
        Posix.system ("find %s -name '%s' > tmp.tmp".printf (location, keyword));

        string text;

        try {
            FileUtils.get_contents ("tmp.tmp", out text);
        } catch (Error error) {
            print ("Error opening file.\n");
        }

        Posix.system ("rm tmp.tmp");
        string[] results = text.split ("\n");
        List<Result> output = new List<Result> ();

        foreach (string s in results) {
            if (s == "") {
                continue;
            }

            output.append (parseLocation (s));
        }

        return output;
    }
}