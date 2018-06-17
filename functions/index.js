const functions = require('firebase-functions'),
      admin = require('firebase-admin')

admin.initializeApp();

// Requests a timestamp so we don't have to rely on the local device time
exports.getTimeStamp = functions.https.onRequest((req, res)=>{
  res.setHeader('Content-Type', 'application/json');
  res.send(JSON.stringify({ timestamp: Date.now() / 1000.0 }));
});



//Updates single venue when an entry is created
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


// Updates all venues' entries and average calculations
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
			averageWaitTime = (averageWaitTime / entryKeys.length).toFixed(2);
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
			averageWaitTime = (averageWaitTime / entryKeys.length).toFixed(2);
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