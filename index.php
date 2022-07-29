<?php include("header.php");?>
<!-- Poupup Template -->
<div id="popuptemplate"></div>

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
  <!-- Poupup Template -->
  <div id="popuptemplate"></div>
  <br /><br />
  <table class="table sortable">
    <thead>
      <tr>
        <th scope="col">#</th>
        <th scope="col">CPU</th>
        <th scope="col">Cores</th>
        <th scope="col">RAM</th>
        <th scope="col">Kernel</th>
        <th scope="col">Total disk space</th>
	      <th scope="col">Disk Type</th>
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
        
        $sql = "SELECT * FROM web.benchmarks ";
        if($_GET['sort'] == "nameasc"){$sql .= "ORDER BY cpu ASC";}
        if($_GET['sort'] == "namedec"){$sql .= "ORDER BY cpu DESC";}
        $sql .= ";";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
        // output data of each row
        while($row = $result->fetch_assoc()) {
            $row_class = "";
            $disk_class = "";
            if($row['type'] == "dedi_nfs"){  $disk_class = "class=\"nfs\"";}
            if($row['type'] == "unknown"){  $row_class = "class=\"unknown\"";}
            if($row['type'] == "vps"){  $row_class = "class=\"vps\"";}
            if($row['type'] == "vds"){  $row_class = "class=\"vds\"";}
          
            echo "<tr " . $row_class . ">";
            echo "<th scope=\"row\"><span class=\"invnummer\"  onclick=\"createpopup(" .$row["bench_id"]. ")\">" . $row["bench_id"] . "</span></th>";
            echo "<td>" . $row["cpu"] . "</td><td>" . $row["cpucores"] . "</td>";
            echo "<td>" . mbytes_to_human($row["ram"]) . "</td><td>" . $row["kernel"] . "</td><td $disk_class>" . bytes_to_human($row['disk_available']) . "</td><td $disk_class>" . $row['disk_type'] . "</td>";    
            
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
<script>


function createpopup(number){
  removepopup("popup");
  theUrl = "popup.php?id=" + number;
  var xmlHttp = null;
  xmlHttp = new XMLHttpRequest();
  xmlHttp.open("GET", theUrl, false);
  xmlHttp.send(null);

  var div = document.createElement('div');
  div.innerHTML = xmlHttp.responseText.trim();

  // Change this to div.childNodes to support multiple top-level nodes.
  document.getElementById("popuptemplate").appendChild(div);
}


function removepopup(className){
    const elements = document.getElementsByClassName(className);
    while(elements.length > 0){
        elements[0].parentNode.removeChild(elements[0]);
    }
}
</script>

<?php include("footer.php"); ?>




