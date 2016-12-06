<?php
// setup our include path, this is needed since the script is run from cron
ini_set("include_path", ".:../:./include:../include:/etc/haproxy/config");
ini_set('display_errors', 'On');
error_reporting(E_ALL);
$today=date('Y-m-d h:i:s');


// including the Amazon EC2 PHP Library
require '/root/vendor/autoload.php';
#require '/root/vendor/aws/aws-sdk-php/src/AwsClient.php';

// location of AMI of the application image
$ami_id = "ami-95e0c982";

// connect to Amazon and pull a list of all running instances
use Aws\Ec2\Ec2Client;

$service = new EC2Client(['profile' => 'default',
'region' => 'us-east-1',
'version' => 'latest']);
$request = array();
#$response = $service->describeInstances($request);
#$response = system("aws ec2 describe-instances");
$describeInstancesResult = $service->DescribeInstances($request);
$reservationList = $describeInstancesResult['Reservations'];


// loop the list of running instances and match those that have an AMI of the application image
$hosts = array();
foreach ($reservationList as $reservation) {
        $runningInstanceList = $reservation['Instances'];
        foreach ($runningInstanceList as $runningInstance) {
		
		$ami = $runningInstance['ImageId'];
		
                $state = $runningInstance['State']['Name'];

                if ($ami == $ami_id && $state == 'running') {

                        $dns_name = $runningInstance['PrivateDnsName'];

                        $app_ip = gethostbyname($dns_name);

                        $hosts[] = $app_ip;
                }
	}
}

// get our default HAProxy configuration file
$haproxy_cfg = file_get_contents("/etc/haproxy/haproxy.cfg.bak");

foreach ($hosts as $i=>$ip) {
        $haproxy_cfg .= 'server api'.$i.' '.$ip.':80 weight 1 check
';
}
// test if the configs differ
$current_cfg = file_get_contents("/etc/haproxy/haproxy.cfg");
if ($current_cfg == $haproxy_cfg) {
        echo "$today everything is good, configs are the same.\n";
}
else {
        echo "$today file out of date, updating.\n";
        file_put_contents("/etc/haproxy/haproxy_2.cfg",$haproxy_cfg);
	system("cp /etc/haproxy/haproxy_2.cfg /etc/haproxy/haproxy.cfg");
        system("/etc/init.d/haproxy reload");
}
?>
