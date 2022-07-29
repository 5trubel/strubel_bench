<?php
include("config.php");

ini_set('display_errors', "E_ALL");

function bytes_to_human($size, $precision = 2) {
    $units = array('B','kB','MB','GB','TB','PB','EB','ZB','YB');
    $step = 1024;
    $i = 0;
    while (($size / $step) > 0.9) {
        $size = intval($size) / intval($step);
        $i++;
    }
    return round($size, $precision).$units[$i];
  }
  
  function mbytes_to_human($size, $precision = 2) {
    $units = array('kB','MB','GB','TB','PB','EB','ZB','YB');
    $step = 1024;
    $i = 1;
    while (($size / $step) > 0.9) {
        $size = intval($size) / intval($step);
        $i++;
    }
    return round($size, $precision).$units[$i];
  }
  
?>

<head>
    <script src="sorttable.js"></script>
    <meta charset="utf-8"/>
    <link rel="stylesheet" type="text/css" href="media/bootstrap-4.0.0.css">
    <link rel="stylesheet" type="text/css" href="media/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js">
    </script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js">
    </script>
    </script>
    <script>
        document.addEventListener('click', function (e) {
            if (e.target.classList.contains('navbar-toggler')) {
                e.target.children[0].classList.toggle('active');
            }
        })
    </script>
    <title>Gaab-Networks Benchmarks</title>
</head>
<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="#">Gaab-Networks Benchmarks</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav"
        aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="benchmark_api.sh">Script</a>
            </li>
        </ul>
    </div>
</nav>