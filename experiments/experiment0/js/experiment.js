function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function make_slides(f) {
  var slides = {};

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
      $("#total-num").html(exp.numTrials);
      $("#total-time").html(7);
     }
  });

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.trial = slide({
    name: "trial",

    present :  exp.stims,

    present_handle : function(stim) {

      this.startTime = Date.now();
      this.stim = stim;

      $(".err").hide();
      $("#question").hide();
      $("#explanandum").html(capitalizeFirstLetter(
        stim.explanandum)
      );

      $("#video-src").remove();
      $("#video-container").html(
        "<video id='video' autoplay muted " +
        "onended='_s.showQuestion()'>" +
        "<source src='" + stim.videoFile +
        "' id='video-src' type='video/mp4'>" +
        "Your browser dows not support the video tag." +
        "</video>"
      );

    },

    showQuestion : function() {
      var stim=this.stim;
      $("#video").attr("controls","controls")
      $("#question").show();
    },

    button : function() {

      this.rt = (Date.now() - this.startTime)/1000;
      var success = this.log_responses();

      /* use _stream.apply(this); if and only if there is
      "present" data. (and only *after* responses are logged) */
      if (success) {
        _stream.apply(this);
      } else {
        $(".err").show();
      }

    },

    log_responses : function() {
      var response = $("#response").val();
      if (response.length > 0) {
        $("#response").val("");
        exp.data_trials.push({
          response: response,
          video: this.stim.videoTag,
          explanandum: this.stim.explanandum
        });
        return true;
      } else {
        return false;
      }
    }

  });


  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        assess : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        problems: $("#problems").val(),
        fairprice: $("#fairprice").val(),
        comments : $("#comments").val()
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {

      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {

/*  repeatWorker = false;
  (function(){
      var ut_id = "erindb-explanation-20160619";
      if (UTWorkerLimitReached(ut_id)) {
        $('.slide').empty();
        repeatWorker = true;
        alert("You have already completed the maximum number of HITs allowed by this requester. Please click 'Return HIT' to avoid any impact on your approval rating.");
      }
  })();
*/

  exp.trials = [];
  exp.catch_trials = [];

  exp.instructions = "instructions";

  var stims = [
      {
        videoFile: 'stims/alma.mp4',
        videoTag: 'alma',
        explanandum: 'the girl took off her glove'
      },
      {
        videoFile: 'stims/bumpy-ride.mp4',
        videoTag: 'bumpy-ride',
        explanandum: 'the girl held her hair above her head'
      },
      {
        videoFile: 'stims/the-gift.mp4',
        videoTag: 'the-gift',
        explanandum: 'the parents hugged the girl'
      },
      {
        videoFile: 'stims/carrot-crazy.mp4',
        videoTag: 'carrot-crazy',
        explanandum: 'the man pulled the carrot out of the ground'
      },
      {
        videoFile: 'stims/destiny.mp4',
        videoTag: 'destiny',
        explanandum: 'the man looked at his time piece'
      }
  ]
  var ntrials = stims.length;

  exp.numTrials = ntrials;

  var shuffledStims = _.shuffle(stims);

  exp.stims = shuffledStims;

  exp.system = {
    Browser : BrowserDetect.browser,
    OS : BrowserDetect.OS,
    screenH: screen.height,
    screenUH: exp.height,
    screenW: screen.width,
    screenUW: exp.width
  };

  exp.structure = [
    "i0",
    "instructions",
    'trial',
    "subj_info",
    "thanks"
  ];

  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length();
  //this does not work if there are stacks of stims (but does work for an experiment with this structure)
  //relies on structure and slides being defined

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  exp.go(); //show first slide
}
