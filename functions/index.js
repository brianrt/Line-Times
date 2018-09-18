const functions = require('firebase-functions'),
      admin = require('firebase-admin')

admin.initializeApp();
const {OAuth2Client} = require('google-auth-library');
const {google} = require('googleapis');

// TODO: Use firebase functions:config:set to configure your googleapi object:
// googleapi.client_id = Google API client ID,
// googleapi.client_secret = client secret, and
// googleapi.sheet_id = Google Sheet id (long string in middle of sheet URL)
const CONFIG_CLIENT_ID = functions.config().googleapi.client_id;
const CONFIG_CLIENT_SECRET = functions.config().googleapi.client_secret;
const CONFIG_SHEET_ID = functions.config().googleapi.sheet_id;

// setup for OauthCallback
const DB_TOKEN_PATH = '/api_tokens';

// The OAuth Callback Redirect.
const FUNCTIONS_REDIRECT = `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/oauthcallback`;

// setup for authGoogleAPI
const SCOPES = ['https://www.googleapis.com/auth/spreadsheets'];
const functionsOauthClient = new OAuth2Client(CONFIG_CLIENT_ID, CONFIG_CLIENT_SECRET,
  FUNCTIONS_REDIRECT);

// Radius for location check
var radius = 50.0 //meters

// Time for time check
var timeInterval = 1800.0 //seconds

// OAuth token cached locally.
let oauthTokens = null;

//Things for authenticated https request
const express = require('express');
const cookieParser = require('cookie-parser')();
const cors = require('cors')({origin: true});
const app = express();

// visit the URL for this Function to request tokens
exports.authgoogleapi = functions.https.onRequest((req, res) => {
  res.set('Cache-Control', 'private, max-age=0, s-maxage=0');
  res.redirect(functionsOauthClient.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
    prompt: 'consent',
  }));
});

// after you grant access, you will be redirected to the URL for this Function
// this Function stores the tokens to your Firebase database
exports.oauthcallback = functions.https.onRequest((req, res) => {
	res.set('Cache-Control', 'private, max-age=0, s-maxage=0');
	const code = req.query.code;
	functionsOauthClient.getToken(code, (err, tokens) => {
	    // Now tokens contains an access_token and an optional refresh_token. Save them.
	    if (err) {
	      	return res.status(400).send(err);
	    }
	    return admin.database().ref(DB_TOKEN_PATH).set(tokens).then(() => {
			return res.status(200).send('App successfully configured with new Credentials. ' + 'You can now close this page.');
		});
  	});
});

// Express middleware that validates Firebase ID Tokens passed in the Authorization HTTP header.
// The Firebase ID token needs to be passed as a Bearer token in the Authorization HTTP header like this:
// `Authorization: Bearer <Firebase ID Token>`.
// when decoded successfully, the ID Token content will be added as `req.user`.
const validateFirebaseIdToken = (req, res, next) => {
 	console.log('Check if request is authorized with Firebase ID token');

	if ((!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) && !(req.cookies && req.cookies.__session)) {
		console.error('No Firebase ID token was passed as a Bearer token in the Authorization header.',
		    'Make sure you authorize your request by providing the following HTTP header:',
		    'Authorization: Bearer <Firebase ID Token>',
		    'or by passing a "__session" cookie.');
		res.status(403).send('Unauthorized');
		return;
	}

	let idToken;
	if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
		console.log('Found "Authorization" header');
		// Read the ID Token from the Authorization header.
		idToken = req.headers.authorization.split('Bearer ')[1];
	} else if(req.cookies) {
		console.log('Found "__session" cookie');
		// Read the ID Token from cookie.
		idToken = req.cookies.__session;
	} else {
		// No cookie
		res.status(403).send('Unauthorized');
		return;
	}
	admin.auth().verifyIdToken(idToken).then((decodedIdToken) => {
		console.log('ID Token correctly decoded', decodedIdToken);
		req.user = decodedIdToken;
		return next();
	}).catch((error) => {
		console.error('Error while verifying Firebase ID token:', error);
		res.status(403).send('Unauthorized');
	});
};


// More things for https authentication
app.use(cors);
app.use(cookieParser);
app.use(validateFirebaseIdToken);

// Main business logic for handling a userSubmitEntry request
app.post('/:userSubmitEntry', (req, res) => {
	var body = req.body;

	//Grab common variables from request
	var username = body.Username;
	var uid = body.Uid;
	var userLat = body.Latitude;
	var userLon = body.Longitude;
	var category = body.CategoryType;
	var name = body.VenueName;
	var comment = body.VenueName;
	var locationDisabled = body.DisableLocation;

	//************ Perform multiple checks to see if it is an allowed request ************

	// Check location to see if they are at the venue
	return admin.database().ref(`Categories/${category}/${name}/coord`).once('value', (snapshot) => {
		var data = snapshot.val();
		var venueLat = data["lat"];
		var venueLon = data["lng"];

		var distance = calculateDistance(userLat,userLon,venueLat,venueLon);

		if (distance < radius || locationDisabled){ // We are at the venue, can continue with our checks
			// Check for a past entry here for this user in the past 30 minutes
			return admin.database().ref(`Users/${uid}`).once('value', (snapshot) => {
				var data = snapshot.val();
				var entryCount = data["entryCount"];
				console.log("entryCount: "+entryCount);
			});

			res.send(JSON.stringify({ title: "Success", message: "Thanks for your submission." }));


		} else { // We are not at the venue, stop here and return an error
			res.send(JSON.stringify({ title: "Not at Location", message: "You must be at the venue location to submit an entry." }));
			return;
		}
	});
});

function calculateDistance(lat1,lon1,lat2,lon2) {
	var R = 6371; // Radius of the earth in km
	var dLat = deg2rad(lat2-lat1);  // deg2rad below
	var dLon = deg2rad(lon2-lon1); 
	var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *  Math.sin(dLon/2) * Math.sin(dLon/2); 
	var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d = R * c; // Distance in km
	return d * 1000;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
}

// This HTTPS endpoint can only be accessed by your Firebase Users.
// Requests need to be authorized by providing an `Authorization` HTTP header
// with value `Bearer <Firebase ID Token>`.
exports.app = functions.https.onRequest(app);

function getToday(){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!

	var yyyy = today.getFullYear();
	if(dd<10){
	    dd='0'+dd;
	} 
	if(mm<10){
	    mm='0'+mm;
	} 
	return mm+'/'+dd+'/'+yyyy;
}

// trigger function to write to Sheet when new data comes in on Feedback
exports.appendFeedbackToSpreadsheet = functions.database.ref(`Feedback/{ITEM}`).onCreate((snapshot, context) => {
	const newRecord = snapshot.val();
	console.log(newRecord);
	var userID = Object.keys(snapshot.val())[0];
	var email = context.auth.token.email
	var feedback = newRecord[userID];
	var date = getToday();
	return appendPromise({
		spreadsheetId: CONFIG_SHEET_ID,
		range: 'A:D',
		valueInputOption: 'USER_ENTERED',
		insertDataOption: 'INSERT_ROWS',
		resource: {
			values: [[userID, email, feedback, date]],
		},
	});
});

// accepts an append request, returns a Promise to append it, enriching it with auth
function appendPromise(requestWithoutAuth) {
  return new Promise((resolve, reject) => {
    return getAuthorizedClient().then((client) => {
      const sheets = google.sheets('v4');
      const request = requestWithoutAuth;
      request.auth = client;
      return sheets.spreadsheets.values.append(request, (err, response) => {
        if (err) {
          console.log(`The API returned an error: ${err}`);
          return reject(err);
        }
        return resolve(response.data);
      });
    });
  });
}

// checks if oauthTokens have been loaded into memory, and if not, retrieves them
function getAuthorizedClient() {
  if (oauthTokens) {
    return Promise.resolve(functionsOauthClient);
  }
  return admin.database().ref(DB_TOKEN_PATH).once('value').then((snapshot) => {
    oauthTokens = snapshot.val();
    functionsOauthClient.setCredentials(oauthTokens);
    return functionsOauthClient;
  });
}

// Requests a timestamp so we don't have to rely on the local device time
exports.getTimeStamp = functions.https.onRequest((req, res)=>{
  res.setHeader('Content-Type', 'application/json');
  res.send(JSON.stringify({ timestamp: Date.now() / 1000.0 }));
});

// Clears out old user entry time stamps under user data daily, runs daily at midnight
exports.cleanUserData = functions.https.onRequest((req, res)=>{
	const currentTime = Date.now() / 1000.0;
    return admin.database().ref('Users/').once('value', (snapshot) => {
		var data = snapshot.val();
		var userIDs = Object.keys(snapshot.val());
		return cleanSingleUser(0, userIDs, data, currentTime, res);
	});
});


function cleanSingleUser(i, userIDs, data, currentTime, res){
	console.log(i);
	var timeDiff = 1800;
	var userID = userIDs[i];
	var user = data[userID];
	var entryData = user["Entries"];
	if(entryData != undefined){
		var venues = Object.keys(entryData);
		for(var j = 0; j < venues.length; j++){
			var venue = venues[j];
			var venueData = entryData[venue];
			var pushID = Object.keys(venueData)[0];
			var timeStamp = venueData[pushID];
			if(currentTime - timeStamp >= timeDiff){
				delete entryData[venue];
			}
		}
		return admin.database().ref(`Users/${userID}/Entries`).set(entryData).then(() => {
			if(i < userIDs.length - 1){
				i = i + 1;
				return cleanSingleUser(i, userIDs, data, currentTime, res);
			} else {
				res.send("Done");
				return;
			}
		});
	} else {
		if(i < userIDs.length - 1){
			i = i + 1;
			return cleanSingleUser(i, userIDs, data, currentTime, res);
		} else {
			res.send("Done");
			return;
		}
	}
}

// Updates single venue when an entry is created
exports.refreshSingleVenue = functions.database.ref('Categories/{category}/{venue}/Entries/{pushID}').onCreate((snapshot, context) => {
	console.log("running refreshSingleVenue full");
	const currentTime = Date.now() / 1000.0;
	var category = context.params.category;
	var venue = context.params.venue;

	return admin.database().ref(`Categories/${category}/${venue}`).once('value', (snapshot) => {
		var content = snapshot.val();
		var data = {};
		data[venue] = content;
		venues = [venue];

		switch(category){
			case "Restaurants":
				return refreshSingleRestaurant(0, venues, category, data, currentTime);
			case "Bars":
				return refreshSingleBar(0, venues, category, data, currentTime);
			default:
				return refreshSingleDefault(0, venues, category, data, currentTime);
		}
	});
});


// Updates all venues' entries and average calculations, run every 15 minutes
exports.refreshVenues = functions.https.onRequest((req, res)=>{
  	const currentTime = Date.now() / 1000.0;
    return admin.database().ref('Categories/').once('value', (snapshot) => {
		var data = snapshot.val();
		var categories = Object.keys(snapshot.val());
		return refreshSingleCategory(0, categories, data, currentTime).then(() => {
			return res.send("Done");
		});
	});
});

function refreshSingleCategory(i, categories, data, currentTime){
	var category = categories[i];
	switch(category){
		case "Restaurants":
			return refreshRestaurants(category, data[category], currentTime).then(() => {
				if(i < categories.length-1){
					i = i+1;
					return refreshSingleCategory(i, categories, data, currentTime);
				}
			});
			break;
		case "Bars": 
			return refreshBars(category, data[category], currentTime).then(() => {
				if(i < categories.length-1){
					i = i+1;
					return refreshSingleCategory(i, categories, data, currentTime);
				}
			});
			break;
		default: 
			return refreshDefault(category, data[category], currentTime).then(() => {
				if(i < categories.length-1){
					i = i+1;
					return refreshSingleCategory(i, categories, data, currentTime);
				}
			});
	}
}

//Recursive helper functions for updating the restaurant category
function refreshRestaurants(category, data, currentTime){
	console.log("starting "+category);
	var restaurants = Object.keys(data);
	return refreshSingleRestaurant(0, restaurants, category, data, currentTime);
}

function refreshSingleRestaurant(i, restaurants, category, data, currentTime){
	var restaurant = restaurants[i];
	var restaurantData = data[restaurant];
	var entryDataCandidate = restaurantData["Entries"];
	if(entryDataCandidate == undefined){
		return admin.database().ref(`Categories/${category}/${restaurant}/Average Wait Time`).set("N/A").then(() => {
            if(i < restaurants.length-1){
                i = i+1;
                return refreshSingleRestaurant(i, restaurants, category, data, currentTime);
            }
        });
	} else {
		var entryData = removeOldEntries(entryDataCandidate, currentTime);
		var entryKeys = Object.keys(entryData);
		var averageWaitTimeText = "N/A";

		if(entryKeys.length > 0){
			var averageWaitTime = 0.0;
			for(var j = 0; j < entryKeys.length; j++){
				var entryKey = entryKeys[j];
				var entry = entryData[entryKey];
				var waitTime = parseInt(entry["Wait Time"]);
				averageWaitTime += waitTime;
			}
			averageWaitTime = (averageWaitTime / entryKeys.length).toFixed(1);
			averageWaitTimeText = averageWaitTime.toString();
		}

		return admin.database().ref(`Categories/${category}/${restaurant}/Average Wait Time`).set(averageWaitTimeText).then(() => {
			return admin.database().ref(`Categories/${category}/${restaurant}/Entries`).set(entryData).then(() => {
	            if(i < restaurants.length-1){
	                i = i+1;
	                return refreshSingleRestaurant(i, restaurants, category, data, currentTime);
	            }
      		});
        });
	}
}

//Recursive helper functions for updating the bar category
function refreshBars(category, data, currentTime){
	console.log("starting "+category);
	var bars = Object.keys(data);
	return refreshSingleBar(0, bars, category, data, currentTime);
}

function refreshSingleBar(i, bars, category, data, currentTime){
	var bar = bars[i];
	var barData = data[bar];
	var entryDataCandidate = barData["Entries"];
	if(entryDataCandidate == undefined){
		return admin.database().ref(`Categories/${category}/${bar}/Average Wait Time`).set("N/A").then(() => {
			return admin.database().ref(`Categories/${category}/${bar}/Most Frequent Cover`).set("N/A").then(() => {
	            if(i < bars.length-1){
	                i = i+1;
	                return refreshSingleBar(i, bars, category, data, currentTime);
	            }
	        });                      
        });
	} else {
		var entryData = removeOldEntries(entryDataCandidate, currentTime);
		var entryKeys = Object.keys(entryData);
		var averageWaitTimeText = "N/A";
		var mostFrequentCoverText = "N/A";
		if(entryKeys.length > 0){
			var averageWaitTime = 0.0;
			var covers = [];
			for(var j = 0; j < entryKeys.length; j++){
				var entryKey = entryKeys[j];
				var entry = entryData[entryKey];
				var waitTime = parseInt(entry["Wait Time"]);
				var cover = parseFloat(entry["Cover"]);
				covers.push(cover);
				averageWaitTime += waitTime;
			}
			averageWaitTime = (averageWaitTime / entryKeys.length).toFixed(1);
			var mostFrequentCover = mode(covers).toFixed(2);

			averageWaitTimeText = averageWaitTime.toString()
			mostFrequentCoverText = mostFrequentCover.toString()
		}
		return admin.database().ref(`Categories/${category}/${bar}/Average Wait Time`).set(averageWaitTimeText).then(() => {
			return admin.database().ref(`Categories/${category}/${bar}/Most Frequent Cover`).set(mostFrequentCoverText).then(() => {
				return admin.database().ref(`Categories/${category}/${bar}/Entries`).set(entryData).then(() => {
		            if(i < bars.length-1){
		                i = i+1;
		                return refreshSingleBar(i, bars, category, data, currentTime);
		            }
       			});
       		});
        });
	}
}

//Recursive helper functions for updating the other default categories
function refreshDefault(category, data, currentTime){
	console.log("starting "+category);
	var defaults = Object.keys(data);
	return refreshSingleDefault(0, defaults, category, data, currentTime);
}

function refreshSingleDefault(i, defaults, category, data, currentTime){
	var name = defaults[i];
	var defaultData = data[name];
	var entryDataCandidate = defaultData["Entries"];
	if(entryDataCandidate == undefined){
		return admin.database().ref(`Categories/${category}/${name}/Average Busy Rating`).set("N/A").then(() => {
            if(i < defaults.length-1){
                i = i+1;
                return refreshSingleDefault(i, defaults, category, data, currentTime);
            }
        });
	} else {
		var entryData = removeOldEntries(entryDataCandidate, currentTime);
		var entryKeys = Object.keys(entryData);
		var averageBusyRatingText = "N/A";
		if(entryKeys.length > 0){
			var averageBusyRating = 0.0;
			for(var j = 0; j < entryKeys.length; j++){
				var entryKey = entryKeys[j];
				var entry = entryData[entryKey];
				var busyRating = parseInt(entry["Busy Rating"]);
				averageBusyRating += busyRating;
			}
			averageBusyRating = (averageBusyRating / entryKeys.length).toFixed(1);
			averageBusyRatingText = averageBusyRating.toString();
		}
		return admin.database().ref(`Categories/${category}/${name}/Average Busy Rating`).set(averageBusyRatingText).then(() => {
			return admin.database().ref(`Categories/${category}/${name}/Entries`).set(entryData).then(() => {
	            if(i < defaults.length-1){
	                i = i+1;
	                return refreshSingleDefault(i, defaults, category, data, currentTime);
	            }
        	});
        });
	}
}

function removeOldEntries(entryData, currentTime){
	var timeDiff = 1800;
	var entryKeys = Object.keys(entryData);
	for(var i = 0; i < entryKeys.length; i++){
		var entryKey = entryKeys[i];
		var entry = entryData[entryKey];
		var timeStamp = entry["Time Stamp"];
		if((currentTime - timeStamp) > timeDiff){
			delete entryData[entryKey];
		}
	}
	return entryData;
}

// Returns the most frequent item in an array
function mode(array){
    if(array.length == 0)
        return null;
    var modeMap = {};
    var maxEl = array[0], maxCount = 1;
    for(var i = 0; i < array.length; i++)
    {
        var el = array[i];
        if(modeMap[el] == null)
            modeMap[el] = 1;
        else
            modeMap[el]++;  
        if(modeMap[el] > maxCount)
        {
            maxEl = el;
            maxCount = modeMap[el];
        }
    }
    return maxEl;
}