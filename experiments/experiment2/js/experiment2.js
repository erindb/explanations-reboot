var DEBUG = true;
var debug = function(string) {
  if (DEBUG) {console.log(string)};
};

function span(class_string) {
  return "<span class='variable_word " + class_string + "'>{{}}</span>";
}

function spanify(content, class_string, id) {
  var element = $("<span/>", {
    class: class_string,
    id: id
  });
  element.html(content);
  return element;
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

var alternative_utterances = {
  "E because A": "\"" + (span("E_caps") + " because " + span("A") + ".\""),
  "E because B": "\"" + (span("E_caps") + " because " + span("B") + ".\""),
  "null": "<it>say nothing</it>"
};

var scenarios = _.shuffle([
  {
    A: "you ate fruit A",
    B: "you ate fruit B",
    E: "your stomach hurts"
  },
  {
    A: "you pressed button A",
    B: "you pressed button B",
    E: "the toy played music"
  },
  {
    A: "you have illness A",
    B: "you have illness B",
    E: "you are coughing"
  },
  {
    A: "you took pill A",
    B: "you took pill B",
    E: "you got better"
  },
  {
    A: "you used training method A",
    B: "you used training method B",
    E: "your performance improved"
  },
  {
    A: "you added fertilizer A",
    B: "you added fertilizer B",
    E: "the plant grew"
  },
  {
    A: "you added spice A",
    B: "you added spice B",
    E: "the food tastes better"
  }
]).map(function(variables) {
  return _.extend(
    variables,
    _.fromPairs(
      _.toPairs(variables).map(function(keyval) {
        var key = keyval[0];
        var value = keyval[1];
        return [(key + "_caps"), capitalizeFirstLetter(value)];
      })
    )
  );
});

function make_slides(f) {
  var   slides = {};

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.listener = slide({
    name: "listener",
    present: [
      {
        condition: "dunno",
        scenario_index: 0
      },
      {
        condition: "dunno",
        scenario_index: 1
      },
      {
        condition: "dunno",
        scenario_index: 2
      }
    ],
    present_handle: function() {
      $(".err").hide();
    },
    button : function() {
      response = "dummy_response";//$("#speaker_response").val();
      if (response.length == 0) {
        $(".err").show();
      } else {
        exp.data_trials.push({
          "trial_type" : "speaker",
          "response" : response
        });
        exp.go(); //make sure this is at the *end*, after you log your data
      }
    },
  });

  slides.speaker = slide({
    name: "speaker",
    present: [
      {
        condition: "dunno",
        scenario_index: 3
      },
      {
        condition: "dunno",
        scenario_index: 4
      },
      {
        condition: "dunno",
        scenario_index: 5
      },
      {
        condition: "dunno",
        scenario_index: 6
      }
    ],
    present_handle: function(stim) {
      $(".err").hide();
      _.keys(alternative_utterances).map(function(alternative_utterance) {
        var option = $("<option/>", {value: alternative_utterance});
        option.html(alternative_utterances[alternative_utterance]);
        $("#speaker_response").append(option);
      });
      var scenario = scenarios[stim.scenario_index];
      _.keys(scenario).map(function(variable) {
        $("." + variable).html(scenario[variable]);
      });
    },
    button : function() {
      response = $("#speaker_response").val();
      if (response.length == 0) {
        $(".err").show();
      } else {
        exp.data_trials.push({
          "trial_type" : "speaker",
          "response" : response
        });
        exp.go(); //make sure this is at the *end*, after you log your data
      }
    },
  });

  slides.prob_cause = slide({
    name : "prob_cause",

    /* trial information for this block
     (the variable 'stim' will change between each of these values,
      and for each of these, present_handle will be run.) */
    present : _.shuffle(scenarios),

    //this gets run only at the beginning of the block
    present_handle : function(stim) {
      $(".err").hide();

      this.stim = stim; //I like to store this information in the slide so I can record it later.

      this.init_sliders();
      exp.sliderPost = null; //erase current slider value
    },

    button : function() {
      if (exp.sliderPost == null) {
        $(".err").show();
      } else {
        this.log_responses();

        /* use _stream.apply(this); if and only if there is
        "present" data. (and only *after* responses are logged) */
        _stream.apply(this);
      }
    },

    init_sliders : function() {
      utils.make_slider("#single_slider", function(event, ui) {
        exp.sliderPost = ui.value;
      });
    },

    log_responses : function() {
      exp.data_trials.push({
        "trial_type" : "one_slider",
        "response" : exp.sliderPost
      });
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        comments : $("#comments").val(),
        problems: $("#problems").val(),
        fairprice: $("#fairprice").val()
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
  exp.trials = [];
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure= [
    "i0",
    "instructions"
  ].concat(_.shuffle([
    "speaker",
    "listener"
  ])).concat([
    "prob_cause",
    "subj_info",
    "thanks"
  ]);

  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
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
