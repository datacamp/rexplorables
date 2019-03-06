HTMLWidgets.widget({

  name: 'dc_parsons',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
         if (x.campus){
           setupCampusHandlers();
         }
          var initial = x.code ;

        function displayErrors(fb) {
            var message;
            if(fb.errors.length > 0) {
              console.log(fb.errors[0]);
              message = {success: false, message: fb.errors[0]};
            } else {
              message = {success: true, message: "Well Done!"};
            }
            if (x.campus){
              checkExercise(message.success, message.message);
            }
        }

        var parson = new ParsonsWidget({
                'sortableId': 'sortable',
                'trashId': 'sortableTrash',
                'max_wrong_lines': 1,
                'feedback_cb' : displayErrors
        });
        parson.init(initial);
        parson.shuffleLines();
        $("#newInstanceLink").click(function(event){
          event.preventDefault();
          parson.shuffleLines();
        });
        $("#feedbackLink").click(function(event){
          event.preventDefault();
          parson.getFeedback();
        });
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
