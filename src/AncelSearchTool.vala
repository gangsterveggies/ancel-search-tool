/***
    BEGIN LICENSE

    Copyright (C) 2013 David Gomes <davidrafagomes@gmail.com>

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

using Gtk;

namespace AncelSearchTool {

    public class AncelSearchTool : Granite.Application {

        static string app_shell_name = "ancel-search-tool";

        construct {
            program_name = "Ancel Search Tool";
            exec_name = app_shell_name;
            app_years = "2013";
            app_icon = "";
            app_launcher = "ancel-search-tool.desktop";
            about_authors = { "David Gomes <davidrafagomes@gmail.com>",
                              "Pedro Paredes <gangsterveggies@gmail.com>" };

            // about_documenters = {""};
            about_artists = { "David Gomes <davidrafagomes@gmail.com>" };
            about_translators = "Launchpad Translators";
            about_license_type = License.GPL_3_0;
            
            main_url = "https://github.com/gangsterveggies/ancel-search-tool";
            bug_url = "https://github.com/gangsterveggies/ancel-search-tool/issues";
        }

        protected override void activate () {
            var window = new AncelSearchToolWindow (this);
            window.show ();
        }

        public AncelSearchTool () {
            Granite.Services.Logger.initialize ("AncelSearchTool");
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        }

        public static int main (string[] args) {
            init (ref args);
            var app = new AncelSearchTool ();
            return app.run (args);
        }
    }
}
