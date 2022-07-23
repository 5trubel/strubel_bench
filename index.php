<?php include("header.php"); ?>
<!-- Poupup Template -->
<div class="container">
  The definition of things here on this website:
  <table class="table">
    <tbody>
      <td class="nfs">The root system is loaded via NFS (most likely capped at 1 Gbit/s)</td>
      <td class="vps">Virtual private server => resources are shared with other users</td>
      <td class="vds">Virtual dedicated server => resources like CPU cores are not shared between different users</td>
      <td class="unknown">No info was provided</td>
      <td>Complete control over all resources</td>
    </tbody>
  </table>
  <br /><br />
  <table class="table sortable">
    <thead>
      <tr>
        <th scope="col">#</th>
        <th scope="col">CPU</th>
        <th scope="col">Cores</th>
        <th scope="col">RAM</th>
        <th scope="col">Kernel</th>
        <th scope="col">SHA256 (500MB)</th>
	      <th scope="col">BZIP2 (500MB)</th>
        <th scope="col">AES (500MB)</th>
        <th scope="col">ioPing (Min)</th>
        <th scope="col">ioPing (Avg)</th>
        <th scope="col">ioPing (Max)</th>
        <th scope="col">dd (avg, write)</th>
        <th scope="col">Ranking Index</th>
      </tr>
    </thead>
    <tbody>
      <?php
        // Create connection
        $conn = new mysqli($servername, $username, $password, $dbname);
        // Check connection
        if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
        }

        $sql = "SELECT * FROM web.benchmarks;";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
        // output data of each row
        while($row = $result->fetch_assoc()) {
            $row_class = "";
            $disk_class = "";
            if($row['type'] == "dedi_nfs"){  $disk_class = "class=\"nfs\"";}
            if($row['type'] == "vps"){  $row_class = "class=\"vps\"";}
            if($row['type'] == "vds"){  $row_class = "class=\"vds\"";}
          
            echo "<tr " . $row_class . ">";
            echo "<th scope=\"row\"><span class=\"invnummer\">" . $row["bench_id"] . "</span></th>";
            echo "<td>" . $row["cpu"] . "</td><td>" . $row["cpucores"] . "</td>";
            echo "<td>" . $row["ram"] . " MB</td><td>" . $row["kernel"] . "</td><td>" . $row['sha256_500'] . " s</td>";
            echo "<td>" . $row['bzip2_500'] . " s</td><td>" . $row['aes_500'] . " s</td><td " . $disk_class . ">" . $row['ioping_min'] . " μs</td>";
            echo "<td " . $disk_class . ">" . $row['ioping_avg'] . " μs</td><td " . $disk_class . ">" . $row['ioping_max']. " μs</td><td " . $disk_class . ">" . $row['dd_avg'] . " MiB/s</td><td>TBA</td>";
            echo "</tr>";
          }
        } else {
        echo "0 results";
        }
        $conn->close();
        ?>
    </tbody>
  </table>
  <br /><br /><br />
  <h3>Disclaimer:</h3>
  <p>1. As written by the original author "n-st", running scripts from an unknown source that downloads an unknown binary is a security risk, I try my best to make it as safe as possible, <span class="bold">but it is your responsibility</span>. I am not responsible for any damage caused by running this script! If you don't trust me or don't like this script, <span class="bold">don't use it!</span></p>  
  <p>2. I don't know how good this benchmark is, I'm open to improvement, but please don't use these values for production or outside this site.</p>
  <p>You can find my mail in the imprint</p>
</div>

<?php include("footer.php"); ?>




