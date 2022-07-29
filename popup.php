<?php
include("config.php");

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



$id = $_GET['id'];

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM benchmarks WHERE bench_id = \"" . mysqli_real_escape_string($conn,$id) . "\";";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
// output data of each row
while($row = $result->fetch_assoc()) {
  if($row['type'] == "dedi"){  $type = "Dedicated Server"; }
  if($row['type'] == "dedi_nfs"){  $disk_class = "nfs"; $type = "Dedicated Server /w Root on NFS"; }
  if($row['type'] == "unknown"){  $row_class = "unknown"; $type = "Unknown"; }
  if($row['type'] == "vps"){  $row_class = "vps"; $type = "vServer"; }
  if($row['type'] == "vds"){  $row_class = "vds"; $type = "Virtual Dedicated Server"; }
    ?>
    <div class="popup">
      <a onclick="removepopup('popup')" id="popup_close" class="popup_close">X</a>
      <!-- <img src="https://via.placeholder.com/320x180.png?text=Template" \> -->
      <?php
        //if($row['image'] == ""){ echo "<img src=\"https://via.placeholder.com/320x180.png?text=".$row['name']."\" \>";}else{echo "<img width=\"320\" src=\"php/getimage.php?num=$id\" \>";}
      ?>
      <br />
      <p>Type: <?php echo $type; ?></p>
      <p>CPU: <?php echo $row['cpu']; ?></p>
      <p> Cores: <?php echo $row['cpucores']; ?></p>
      <p>RAM: <?php echo mbytes_to_human($row['ram']); ?></p>
      <p>Kernel: <?php echo $row['kernel']; ?></p>
      <p class="<?php echo $disk_class; ?>">Disktype: <?php echo $row['disk_type']; ?></p>
      <p class="<?php echo $disk_class; ?>"> Disk space: <?php echo bytes_to_human($row['disk_available']); ?></p>
      <div class="popup_notes">
        <p>Benchmarks:</p>
        <span class="poup_note_text">SHA256 (500MB): <?php echo $row['sha256_500']; ?></span><br />
        <span class="poup_note_text">BZIP2 (500MB): <?php echo $row['bzip2_500']; ?></span><br />
        <span class="poup_note_text">AES (500MB): <?php echo $row['aes_500']; ?></span><br />
        <span class="poup_note_text <?php echo $disk_class; ?>">ioPing Low: <?php echo $row['ioping_min']; ?></span><br />
        <span class="poup_note_text <?php echo $disk_class; ?>">ioPing High: <?php echo $row['ioping_max']; ?></span><br />
        <span class="poup_note_text <?php echo $disk_class; ?>">ioPing Avg: <?php echo $row['ioping_avg']; ?></span><br />
        <span class="poup_note_text <?php echo $disk_class; ?>">DD (Write/Avg): <?php echo mbytes_to_human($row['dd_avg']); ?>/s</span><br />
      </div>
    </div>
    <?php
}
} else {
echo "Not found...";
}
$conn->close();
?>
