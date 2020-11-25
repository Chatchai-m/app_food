<?php

// echo "Chatchai ";
// exit;

define('API_ACCESS_KEY', 'AAAAg2r2EMA:APA91bFZpe0_PGbZ4710RTBKKUClTUlAKaJp9_PDBY7DzXNbMSpoSYKiiMBv0qtowMZw12_56MbJfTjwzzj60YHdMp5SUPGPPvJsAQGQkbMTQpIZuZlQjifZ66Nx86rlyeqBljMPEJyp');

$fcmUrl = 'https://fcm.googleapis.com/fcm/send';

$tokens = [
  "e44Ls-4CSLW3rK_SZ32nxW:APA91bGM1jvjmJM_bg8Qp37C4sS2TaXBPvjpKitFad4F9_LeQ4p8pzFAEqflWYn0OsS2ASKRwB7S_vsWJz-wnRYOcujDRfQ-6f0ulebJpymsiLpxEeWmsUO2KgkFMaTRs6NVguLxEXgs",
  "eUAwsIIcQWuo1no2hcZ8md:APA91bGdcHKoOCgnvSK_YWeOFcv5GopjZfoQaNzwQTCigkPj9Euqq_CfLsrqwoJ69QZ-rMLtOxr2-S6q8XhJkbu0rfmbJNXhYs96Buc3sdl8EU5qg_GA1hTJ15lptJIHDuItzlHffJfX",
];

foreach ($tokens as $key => $val)
{
  $token = $val;
  $notification = [
  //write title, description and so on
    'title' =>'สรุป Ratio ทางพื้นฐานหุ้นโรงไฟฟ้า',
    'body' => 'Hello world',
    // 'icon' =>'myIcon', 
    // 'sound' => 'mySound',
    "image" => "https://blog.labhoon.com/wp-content/uploads/2020/11/125200854_3385018401617209_3737635295567599872_n-1024x576.png"

  ];

  $extraNotificationData = [
    "message" => $notification,
    "moredata" =>'dd',
  ];

  $fcmNotification = [
    //'registration_ids' => $tokenList, //multple token array
    'to'        => $token, //single token
    'notification' => $notification,
    // 'data' => $extraNotificationData
  ];

  $headers = [
    'Authorization: key=' . API_ACCESS_KEY,
    'Content-Type: application/json'
  ];


  $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL,$fcmUrl);
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
  curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fcmNotification));
  $result = curl_exec($ch);
  curl_close($ch);

  echo $result;
}


?>
