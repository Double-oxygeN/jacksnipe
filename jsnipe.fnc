###########################################################################
# Copyright 2017 Double_oxygeN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################

jsnipe()
{
  local username="{username here}"

  if [ $1 = "new" ]; then
    if [ -d $2 ]; then
      echo "$2 directory already exists."
    else
      mkdir $2
      cd $2/

      readme_framework $2 $username

      mkdir docs
      cd docs

      mkdir resources
      mkdir libraries
      html_framework $2
      js_framework
      css_framework

      cd ../..
      if [ $? = 0 ]; then
        echo "New project $2 was created."
      else
        echo "There is something wrong."
      fi
    fi
  elif [ $1 = "run" ]; then
    open docs/index.html
  elif [ $1 = "test" ]; then
    jsc .test.js
  else
    echo "makejs: $1 - command not found"
  fi
}

html_framework()
{
cat << EOT > index.html
<!DOCTYPE html>
<html lang="ja">

<head>
  <meta charset="utf-8">
  <title>$1</title>
  <link rel="stylesheet" type="text/css" href="style.css"></link>
  <script type="text/javascript" src="libraries/lib.js"></script>
</head>

<body>
  <h1>$1</h1>
  <p id="hello"></p>

  <script type="text/javascript" src="main.js"></script>
</body>

</html>
EOT
}

js_framework()
{
cat << EOT > libraries/lib.js
/**
 * Copyright 2017 Double_oxygeN
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

function Library() {
  this.average = arr => arr.reduce((a, b) => a + b) / arr.length;
  this.cauchyRand = function () {
    return Math.tan(Math.PI * (Math.random() - 0.5));
  };
  this.clone = function (obj) {
    switch (this.type(obj)) {
    case 'Object':
      return Object.assign({}, obj);
    case 'Array':
      return obj.concat();
    default:
      return obj;
    }
  };
  this.cycle = function (pattern, length) {
    let l = length || 0xffff,
      p_l = pattern.length,
      arr = [],
      c = 0;

    while (c < l) {
      arr.push(pattern[c % p_l]);
      c = c + 1;
    }
    return arr;
  };
  this.expRand = function () {
    return -Math.log(Math.random());
  };
  this.frequencies = function (ary) {
    let result = {};
    ary.forEach(e => {
      if (e in result) {
        result[e] += 1;
      } else {
        result[e] = 1;
      }
    });
    return result;
  };
  this.gaussRand = function () {
    return Math.sqrt(2 * this.expRand()) * Math.sin(2 * Math.PI * Math.random());
  };
  this.groupBy = function (f, ary) {
    let result = {};
    ary.forEach(e => {
      if (f(e) in result) {
        result[f(e)].push(e);
      } else {
        result[f(e)] = [e];
      }
    });
    return result;
  };
  this.identity = x => x;
  this.iterate = function (f, first_args, length) {
    let l = length || 0xffff,
      arr = [],
      c = 0;

    while (c < l) {
      arr.push((c === 0) ? first_args : f(arr[c - 1]));
      c = c + 1;
    }
    return arr;
  };
  this.pipe = function () {
    if (arguments[1]) {
      let args = this.toArray(arguments);
      return this.pipe.apply(this, [args[1][0].apply(this, [args[0]].concat(args[1].slice(1)))].concat(args.slice(2)));
    } else {
      return arguments[0];
    }
  };
  this.range = function (start, end, step) {
    let arr = [],
      st = start || 0,
      ed = end || 0xffff,
      sp = step || 1;
    while (st < ed) {
      arr.push(st);
      st = st + sp;
    }
    return arr;
  };
  this.repeat = function (element, length) {
    let l = length || 0xffff,
      arr = [],
      c = 0;
    while (c < l) {
      arr.push(this.clone(element));
      c = c + 1;
    }
    return arr;
  };
  this.repeatedly = function (f, length) {
    let l = length || 0xffff,
      arr = [],
      c = 0;
    while (c < l) {
      arr.push(f());
      c = c + 1;
    }
    return arr;
  };
  this.rest = function (arr) {
    return arr.slice(1);
  };
  this.shuffle = function (arr) {
    let sarr = this.clone(arr),
      l = arr.length,
      c = l - 1;

    while (c > 0) {
      let r = (Math.random() * (c + 1)) | 0;
      [sarr[c], sarr[r]] = [sarr[r], sarr[c]];
      c = c - 1;
    }

    return sarr;
  };
  this.sq = x => x * x;
  this.std_dev = function (arr) {
    let av = this.average(arr);
    return Math.sqrt(this.average(arr.map(e => this.sq(av - e))));
  };
  this.time = function (rep_times, f, _that, _args) {
    let stat = new Array(rep_times),
      results = new Array(rep_times),
      c = rep_times - 1,
      st, et, avg, sdv,
      that = _that || this,
      args = _args || [];

    try {
      while (-1 < c) {
        st = new Date();
        results[c] = f.apply(that, args);
        et = new Date();
        stat[c] = (et - st) | 0;
        c = (c - 1) | 0;
      }

      avg = this.average(stat);
      sdv = this.std_dev(stat);
      console.log("executed function for " + rep_times.toString(10) + " times.");
      console.groupCollapsed("STATISTICS");
      console.log("average: " + avg.toString(10) + " [ms]");
      console.log("standard deviation: " + sdv.toString(10) + " [ms]");
      console.log(results);
      console.groupEnd();
    } catch (e) {
      console.error("ERROR: " + e.message);
    }

    return null;
  };
  this.toArray = function (obj) {
    switch (this.type(obj)) {
    case 'Array':
      return obj;
    case 'Arguments':
      return Array.prototype.slice.call(obj);
    case 'Object':
      return Object.keys(obj).map(e => [e, obj[e]]);
    case 'String':
      return obj.split('');
    default:
      return Array.prototype.slice.call(arguments);
    }
  };
  this.type = function (obj) {
    return Object.prototype.toString.call(obj).slice(8, -1);
  };
}
EOT

cat << EOT > main.js
window.onload = function (e) {
  document.getElementById('hello').innerHTML = "Hello, world!";
};
EOT

cat << EOT > ../.test.js
load("./docs/libraries/lib.js");
const console = {
  log: s => print(s),
  warn: s => print("\033[93m" + s + "\033[0m"),
  error: s => print("\033[91m" + s + "\033[0m"),
  group: s => print("\033[44m ---" + s + "---"),
  groupCollapsed: s => print("\033[44m ---" + s + "---"),
  groupEnd: () => print("--- GROUP END --- \033[0m")
};

var _ = new Library();
_.time(10, _.shuffle, _, [_.range(0, 12)]);
EOT
}

css_framework()
{
cat << EOT > style.css
body {
  background-color: #FFFFFF;
}

#hello {
  color: #666666;
}
EOT
}

readme_framework()
{
cat << EOT > README.md
# $1

FIXME: description

## License
This software is licensed under the Apache License, version 2.0
See ./LICENSE

Copyright ©︎ $(date '+%Y') $2
EOT

cat << EOT > .gitignore
.test.js
EOT

curl -s http://apache.org/licenses/LICENSE-2.0.txt | sed -e "s/\[yyyy\]/$(date '+%Y')/g" | sed -e "s/\[name of copyright owner\]/$2/g" > LICENSE
}
