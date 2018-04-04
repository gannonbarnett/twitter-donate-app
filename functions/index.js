// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

//Twitter API set up 

//require_once('TwitterAPIExchange.php');

/** Set access tokens here - see: https://dev.twitter.com/apps/ **/
/**
$settings = array(
    'oauth_access_token' => "2802629606-5QcJ8pZ3zyrq9KSwx4YGhirCKyopVo4nejGICbf",
    'oauth_access_token_secret' => "q1XEzrEV1Ufewfkw1ZbrA74Ty5K6PreWQOyf4Zv7FDQTu",
    'consumer_key' => "c18jxuX7mpK57zNpT5sA3wLRm",
    'consumer_secret' => "3xr1H69nY0bvCpHsSCSOfAGDXqHrWh20wnW0BtJC0U8Z3xsSi9
"
);

/** URL for REST request, see: https://dev.twitter.com/docs/api/1.1/ 
$url = 'https://api.twitter.com/1.1/blocks/create.json';
$requestMethod = 'POST';

/** POST fields required by the URL above. See relevant docs as above 
$postfields = array(
    'screen_name' => 'gannonbarnett', 
    'skip_status' => '1'
);

/** Perform the request and echo the response 
$twitter = new TwitterAPIExchange($settings);
echo $twitter->buildOauth($url, $requestMethod)
             ->setPostfields($postfields)
             ->performRequest();
             
$url = 'https://api.twitter.com/1.1/followers/list.json';
$getfield = '?username=J7mbo&skip_status=1';
$requestMethod = 'GET';
$twitter = new TwitterAPIExchange($settings);
echo $twitter->setGetfield($getfield)
             ->buildOauth($url, $requestMethod)
             ->performRequest(); 
            **/
// Take the text parameter passed to this HTTP endpoint and insert it into the
// Realtime Database under the path /messages/:pushId/original
exports.twitterFunction = functions.https.onRequest((req, res) => {
	
	const original = req.query.handle;
	
	admin.database().ref('/handles').push({handle: original})
	
	//var request = require('request');
	
	// make the request
	request('https://api.twitter.com/1.1/followers/list.json', function (error, response, body) {
		admin.database().ref('/log').push({msg: "made it into twitter request"})
    	if (!error && response.statusCode === 200) {
    		admin.database().ref('/log').push({msg: "made it without error"})
       		return admin.database().ref('/test').push({original: "made it to twitter something"}).then((snapshot) => {
    		// Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
    		return res.redirect(303, snapshot.ref);
  			});
   	 	}
   	 	admin.database().ref('/log').push({msg: "completed with error"})
	})
	
	admin.database().ref('/log').push({msg:"unable to access request"})
	
	return; 	
});

exports.addMessage = functions.https.onRequest((req, res) => {
  // Grab the text parameter.
  const original = req.query.text;
  // Push the new message into the Realtime Database using the Firebase Admin SDK.
  return admin.database().ref('/messages').push({original: original}).then((snapshot) => {
    // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
    return res.redirect(303, snapshot.ref);
  });
});

// Listens for new messages added to /messages/:pushId/original and creates an
// uppercase version of the message to /messages/:pushId/uppercase
exports.makeUppercase = functions.database.ref('/messages/{pushId}/original').onWrite((event) => {
  // Grab the current value of what was written to the Realtime Database.
  const original = event.data.val();
  console.log('Uppercasing', event.params.pushId, original);
  const uppercase = original.toUpperCase();
  // You must return a Promise when performing asynchronous tasks inside a Functions such as
  // writing to the Firebase Realtime Database.
  // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
  return event.data.ref.parent.child('uppercase').set(uppercase);
});
