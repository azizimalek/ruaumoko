# Copyright 2014 (C) Priyesh Patel, Daniel Richman
#
# This file is part of Ruaumoko. 
# https://github.com/cuspaceflight/ruaumoko
#
# Ruaumoko is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ruaumoko is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ruaumoko. If not, see <http://www.gnu.org/licenses/>.

import os
from flask import Flask, abort, jsonify, g

from . import config, Dataset

app = Flask(__name__)

@app.before_first_request
def open_dataset():
    dir = app.config.get('ELEVATION_DIRECTORY', '/opt/elevation')

    global elevation
    elevation = Dataset(dir)

@app.route('/<latitude>,<longitude>')
def main(latitude, longitude):
    try:
        latitude = float(latitude)
        longitude = float(longitude)
    except ValueError:
        abort(400)

    return jsonify({"elevation": elevation.get(latitude, longitude)})
