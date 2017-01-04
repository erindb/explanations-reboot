var labs = _.shuffle([
  "Tondam", "Runcible", "Nanber",
  "Gostak", "Phroxis", "Muckenhoupt",
  "Weyland", "Snarp", "Wrean"
]);
var rat_names = _.shuffle([
  "Fred", "Frank", "Ronald",
  "Florence", "Harold", "Ilana",
  "Albert", "Nellie", "Martha"
]);
var they_found = function(n) {
  if (n==2) {
    return "They found two hormones in their mice and called them hormone A and hormone B.";
  } else if (n==3) {
    return "They found three hormones in their mice and called them hormone A, hormone B, and hormone C."
  } else if (n==4) {
    return "They found four hormones in their mice and called them hormone A, hormone B, hormone C, and hormone D."
  } else {
    alert("warning 2134: that's not a good number. (n=" + n + ")")
  }
};
var write_prompt = function(condition, consequent, rat_name) {
  return "For " + rat_name + " the mouse, if " + condition + ", would " + consequent + "?";
}
var stories = {
  story1: function(lab, rat_name, n_hormones) {
    return "In a very small number of the mice, hormone A is present.<br/>" +
      "In a very small number of the mice, hormone B is present.<br/>" +
      "The presence or absence of hormone A does not depend on the status of hormone B.<br/>" +
      "The presence or absence of hormone B does not depend on the status of hormone A.<br/><br/>" +
      rat_name + " is a mouse from the " + lab + " Lab. You test " + rat_name + " and find that:<br/>" +
      "Hormone A is definitely present.<br/>" + 
      "Hormone B is definitely present.";
  },
  story2: function(lab, rat_name, n_hormones) {
    return "In almost all of the mice, hormone A is absent.<br/>" + 
      "The status of hormone B is caused by the status of hormone A and nothing else.<br/>" + 
      "In many of the mice, if A is present, this causes B to be present.<br/>" + 
      "The status of hormone C is caused by the status of hormone B and nothing else.<br/>" + 
      "In many of the mice, if B is present, this causes C to be present.<br/><br/>" +
      rat_name + " is a mouse from the " + lab + " Lab. You test " + rat_name + " and find that:<br/>" +
      "Hormone A is definitely present.<br/>" +
      "Hormone B is definitely present.<br/>" +
      "Hormone C is definitely present.";
  },
  story3a: function(lab, rat_name, n_hormones) {
    return "In some of the mice, hormone A is present.<br/>" +
      "The status of hormone B is caused by the status of hormone A and nothing else.<br/>" +
      "In a very small number of the mice, if A is present, this causes B to be absent, and if A is absent, this causes B to be present.<br/>" +
      "In the remaining mice, if A is present, this causes B to be present, and if A is absent, this causes B to be absent.<br/><br/>" +
      rat_name + " is a mouse from the " + lab + " Lab. You test " + rat_name + " and find that:<br/>" +
      "Hormone A is definitely present.<br/>" + 
      "Hormone B is definitely not present.";
  },
  story3b: function(lab, rat_name, n_hormones) {
    return "In some of the mice, hormone A is present." + "<br/>" + 
      "In a very small number of the mice, hormone B is present." + "<br/>" + 
      "The status of hormone C is caused by the status of hormones A and B and nothing else." + "<br/>" + 
      "If B is absent, this causes C's status to match A's: if A is present, this causes C to be present, and if A is absent, this causes C to be absent." + "<br/>" + 
      "If B is present, this causes C's status to be the opposite of A's: if A is present, this causes C to be absent, and if A is absent, this causes C to be present.<br/><br/>" +
      rat_name + " is a mouse from the " + lab + " Lab." + "<br/>" + 
      "You test " + rat_name + " and find that:" + "<br/>" + 
      "Hormone A is definitely present." + "<br/>" + 
      "Hormone C is definitely not present."
  },
  story4: function(lab, rat_name, n_hormones) {
    return "In almost all of the mice, hormone A is present.<br/>" + 
      "In almost all of the mice, hormone B is present.<br/>" + 
      "The status of hormone C is caused by the status of hormones A and B and nothing else.<br/>" + 
      "If A is present, this always causes C to be present.<br/>" + 
      "If B is present, this always causes C to be present.<br/>" + 
      "The status of hormone D is caused by the status of hormone C and nothing else.<br/>" + 
      "If C is present, this always causes D to be present.<br/><br/>" + 
      rat_name + " is a mouse from the " + lab + " Lab. You test " + rat_name + " and find that:<br/>" + 
      "Hormone A is definitely not present.<br/>"+
      "Hormone B is definitely not present.<br/>"+
      "Hormone C is definitely not present.<br/>"+
      "Hormone D is definitely not present."
  },
  story5: function(lab, rat_name, n_hormones) {
    return "In many of the mice, hormone A is present.<br/>"+
      "In many of the mice, hormone B is present.<br/>"+
      "The status of hormone C is caused by the status of hormones A and B and nothing else.<br/>"+
      "If hormone A is present, this always causes hormone C to be present.<br/>"+
      "If hormone B is present, this almost always causes hormone C to be present.<br/>"+
      "The presence of hormone D is caused by the presence of hormone C.<br/>"+
      "If hormone C is present, this always causes hormone D to be present.<br/><br/>"+
      rat_name + " is a mouse from the " + lab + " Lab. You test " + rat_name + " and find that:<br/>"+
      "Hormone A is definitely present.<br/>"+
      "Hormone B is definitely present.<br/>"+
      "Hormone C is definitely present.<br/>"+
      "Hormone D is definitely present."
  },
  story6: function(lab, rat_name, n_hormones) {
    return "In some of the mice, hormone A is present.<br/>" +
      "The status of hormone B is caused by the status of hormone A and nothing else.<br/>"+
      "In almost all mice, if A is present, this causes B to be present, and if A is absent, this causes B to be absent. In the remaining mice, if A is present, this causes B to be absent, and if A is absent, this causes B to be present.<br/>"+
      "The status of hormone C is caused by the status of hormone B and nothing else.<br/>"+
      "In almost all mice, if B is present, this causes C to be present, and if B is absent, this causes C to be absent. In the remaining mice, if B is present, this causes C to be absent, and if B is absent, this causes C to be present.<br/><br/>"+
      rat_name + " is a mouse from the " + lab + " Lab. You test " + rat_name + " and find that:<br/>"+
      "Hormone A is definitely not present.<br/>"+
      "Hormone B is definitely not present.<br/>"+
      "Hormone C is definitely present."
  }
};

var all_stims = _.shuffle([
  //story1
  _.shuffle([
    {
      story_name: 'story1',
      story_index: 1,
      n_hormones: 2,
      explanation: "A is present because A is present"
    },
    {
      story_name: 'story1',
      story_index: 1,
      n_hormones: 2,
      explanation: "B is present because A is present"
    },
    {
      story_name: 'story1',
      story_index: 1,
      n_hormones: 2,
      explanation: "A is present because B is present"
    },
    {
      story_name: 'story1',
      story_index: 1,
      n_hormones: 2,
      explanation: "B is present because B is present"
    }
  ]),
  //story2
  _.shuffle([
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "A is present because B is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "B is present because B is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "C is present because B is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "A is present because A is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "B is present because A is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "C is present because A is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "A is present because C is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "B is present because C is present"
    },
    {
      story_name: 'story2',
      story_index: 2,
      n_hormones: 3,
      explanation: "C is present because C is present"
    }
  ]),
  //story3 (a or b)
  _.shuffle([
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "A is present because A is present"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "B is present because A is present"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "C is absent because A is present"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "A is present because B is present"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "B is present because B is present"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "C is absent because B is present"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "A is present because C is absent"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "B is present because C is absent"
    },
    {
      story_name: 'story3b',
      story_index: 3,
      n_hormones: 3,
      explanation: "C is absent because C is absent"
    }
  ]),
  //story4
  _.shuffle([
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "A is absent because A is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "B is absent because A is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "C is absent because A is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "D is absent because A is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "A is absent because B is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "B is absent because B is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "C is absent because B is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "D is absent because B is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "A is absent because C is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "B is absent because C is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "C is absent because C is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "D is absent because C is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "A is absent because D is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "B is absent because D is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "C is absent because D is absent"
    },
    {
      story_name: 'story4',
      story_index: 4,
      n_hormones: 4,
      explanation: "D is absent because D is absent"
    }
  ]),
  //story5
  _.shuffle([
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "A is present because A is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "B is present because A is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "C is present because A is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "D is present because A is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "A is present because B is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "B is present because B is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "C is present because B is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "D is present because B is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "A is present because C is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "B is present because C is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "C is present because C is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "D is present because C is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "A is present because D is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "B is present because D is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "C is present because D is present"
    },
    {
      story_name: 'story5',
      story_index: 5,
      n_hormones: 4,
      explanation: "D is present because D is present"
    }
  ]),
  //story6
  _.shuffle([
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "A is absent because A is absent"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "B is absent because A is absent"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "C is present because A is absent"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "A is absent because B is absent"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "B is absent because B is absent"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "C is present because B is absent"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "A is absent because C is present"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "B is absent because C is present"
    },
    {
      story_name: 'story6',
      story_index: 6,
      n_hormones: 3,
      explanation: "C is present because C is present"
    }
  ])
]);

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

  slides.trial = slide({
    name : "trial",

    /* trial information for this block
     (the variable 'stim' will change between each of these values,
      and for each of these, present_handle will be run.) */
    present : [{}].concat(all_stims.shift()),

    start : function() {
      $(".err").hide();
      var n_hormones = _s.present[1].n_hormones;
      var story_index = _s.present[1].story_index;
      var lab = labs[story_index];
      $(".lab").html(lab);
      $(".present_stuff").hide();
      $(".continue").show();
      var story_intro = "The " + lab + " Lab is studying hormones in mice. " +
                        they_found(n_hormones) + "<br/>";
      $(".story_intro").html(story_intro);
      this.just_beginning = true;
    },

    end : function() {
      _s.present = [{}].concat(all_stims.shift());
    },

    present_handle : function(stim) {
      if (!this.just_beginning) {
        $(".err").hide();
        $(".present_stuff").show();
        $(".answers").show();
        $(".continue").show();

        var story_index = stim.story_index;
        var lab = labs[story_index];
        var rat_name = rat_names[story_index];
        $(".lab").html(lab);

        var story_name = stim.story_name;
        var n_hormones = stim.n_hormones;
        var condition = stim.condition;
        var consequent = stim.consequent;
        this.stim = stim; 

        var previous_story = $(".story").html();
        var new_story = stories[story_name](lab, rat_name, n_hormones);
        $(".story").html(new_story);
        $(".prompt").html("");
        $(".prompt").html(stim.explanation);

        this.init_sliders();
        exp.sliderPost = null; //erase current slider value
      }
    },

    button : function() {
      if (_s.just_beginning) {
        _s.just_beginning = false;
        _stream.apply(this);
      } else {
        if (exp.sliderPost == null) {
          $(".err").show();
        } else {
          this.log_responses();
          $(".answers").hide();
          $(".continue").hide();
          /* use _stream.apply(this); if and only if there is
          "present" data. (and only *after* responses are logged) */
          setTimeout(function() {
            _stream.apply(_s);
          }, 1000);
        }
      }
    },

    init_sliders : function() {
      utils.make_slider("#single_slider", function(event, ui) {
        exp.sliderPost = ui.value;
      });
    },

    log_responses : function() {
      var story_index = _s.stim.story_index;
      exp.data_trials.push({
        "lab_name": rat_names[story_index],
        "mouse_name": labs[story_index],
        "story_index": story_index,
        "story": _s.stim.story_name,
        "explanation": _s.stim.explanation,
        "response": exp.sliderPost
      });
    }
  });

  slides.probabilities = slide({
    name: "probabilities",

    start: function() {
      $(".err").hide();
    },

    button : function() {
      var very_small_number = parseInt($("#very_small_number").val());
      var some = parseInt($("#some").val());
      var many = parseInt($("#many").val());
      var almost_all = parseInt($("#almost_all").val());
      if ( isNaN(very_small_number) | very_small_number < 0 | very_small_number > 100 |
           isNaN(some) | some < 0 | some > 100 |
           isNaN(many) | many < 0 | many > 100 |
           isNaN(almost_all) | almost_all < 0 | almost_all > 100
         ) {
        $(".err").show();
      } else {
        this.log_responses();
        exp.go();
      }
    },

    log_responses : function() {
      var phrases = ["some", "many", "almost_all", "very_small_number"];
      for (var i=0; i<phrases.length; i++) {
        exp.data_trials.push({
          "trial_type": "probability",
          "phrase" : phrases[i],
          "response" : parseInt($("#"+phrases[i]).val())
        });
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
        comments : $("#comments").val(),
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
          "story": exp.story,
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
  repeatWorker = false;
  (function(){
      var ut_id = "explanations-exp4-lk-rep-counterfactuals";
      if (UTWorkerLimitReached(ut_id)) {
        $('.slide').empty();
        repeatWorker = true;
        alert("You have already completed the maximum number of HITs allowed by this requester. Please click 'Return HIT' to avoid any impact on your approval rating.");
      }
  })();

  exp.trials = [];
  exp.catch_trials = [];
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=[
    "i0", "instructions",
    "trial", "trial", "trial", "trial", "trial", "trial",
    //"probabilities",
    'subj_info', 'thanks'
  ];
  
  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = 2 + // intro slides
            6 + // story intro paragraphs
            2*2 + 3*3 + 3*3 + 4*4 + 4*4 + 3*3 + //explanation ratings
            2; //subj info and thanks
    // 19 + 1 + 1 + 2 +5; //utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
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

  if (repeatWorker) {
    $('.slide').empty();
    alert("You have already completed the maximum number of HITs allowed by this requester. Please click 'Return HIT' to avoid any impact on your approval rating.");
  }
  
  exp.go(); //show first slide
}