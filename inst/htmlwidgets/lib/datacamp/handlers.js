setupCampusHandlers();

function setupCampusHandlers(){
  if (typeof(LOCAL) === 'undefined' || !LOCAL) {
    postClientReady();
  }
  if (window.Shiny){
    Shiny.addCustomMessageHandler('campus', function(message){
      checkExercise(message.success, message.message);
    });
  }
}


function checkExercise(success, message) {
  var payload = {success: success, message: message};
  if (typeof(LOCAL) === 'undefined') {
    window.parent.postMessage({
        action: 'CHECK_EXERCISE_COMPLETED',
        channelName: 'NonCodingExerciseInnerFrame',
        payload: payload
      }, '*');
   console.log(JSON.stringify(payload));
  } else {
    alert(JSON.stringify(payload));
  }
}

function postClientReady(){
  const CLIENT_READY = {
    action: 'CLIENT_READY',
    channelName: 'NonCodingExerciseInnerFrame'
  };
  window.parent.postMessage(CLIENT_READY, '*');
}

