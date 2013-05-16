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

public class Result {
    public string location;
    public string name;
    public string type;
    public string parent;

    public Result.null () {
        location = "";
        name = "";
        type = "";
        parent = "";
    }

    public Result (string _location, string _name, string _type, string _parent) {
        location = _location;
        name = _name;
        parent = _parent;

        if (_type != "") {
            type = _type;
        } else {
            type = "Executable";
        }
    }
}
