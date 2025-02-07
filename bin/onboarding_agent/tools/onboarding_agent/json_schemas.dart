Map<String, dynamic> generatePlanSchema = {
  '\$defs': {
    'Goal': {
      'properties': {
        'name': {'description': 'The name of the goal.', 'type': 'string'},
        'duration': {
          'description':
              'The duration of the goal, as a sum of subgoals durations.',
          'type': 'string'
        },
        'subgoals': {
          'description': 'The subgoals of the goal.',
          'items': {'\$ref': '#/\$defs/Subgoal'},
          'type': 'array'
        }
      },
      'required': ['name', 'duration', 'subgoals'],
      'type': 'object'
    },
    'Lesson': {
      'properties': {
        'name': {'description': 'The name of the lesson.', 'type': 'string'},
        'duration': {
          'description': 'The duration of the lesson, maximum 15 minutes.',
          'type': 'string'
        }
      },
      'required': ['name', 'duration'],
      'type': 'object'
    },
    'Subgoal': {
      'properties': {
        'name': {'description': 'The name of the subgoal.', 'type': 'string'},
        'duration': {
          'description':
              'The duration of the subgoal, as a sum of lessons durations.',
          'type': 'string'
        },
        'lessons': {
          'description': 'The lessons of the subgoal.',
          'items': {'\$ref': '#/\$defs/Lesson'},
          'type': 'array'
        }
      },
      'required': ['name', 'duration', 'lessons'],
      'type': 'object'
    }
  },
  'properties': {
    'name': {'description': 'The name of the plan.', 'type': 'string'},
    'duration': {
      'description':
          'The duration of the plan, as a sum of goals durations. Minimum 1 month.',
      'type': 'string'
    },
    'goals': {
      'description': 'The goals of the plan, minimum 3, maximum 5.',
      'items': {'\$ref': '#/\$defs/Goal'},
      'type': 'array'
    }
  },
  'required': ['name', 'duration', 'goals'],
  'type': 'object'
};

Map<String, dynamic> updateUserDataSchema = {
  'type': 'object',
  'properties': {
    'name': {
      'type': 'string',
      'description':
          'The name of the user. Should always be recorded in English and capitalized.'
    },
    'native_language': {
      'type': 'string',
      'description':
          'The native language of the user. Use your best guess based on context.'
    },
    'reason_to_learn_english': {
      'type': 'string',
      'description':
          'The goal of the user for learning the language. Be as descriptive as possible.'
    },
    'interests': {
      'type': 'string',
      'description': 'The interests of the user.'
    },
    'current_level_of_english': {
      'type': 'string',
      'description':
          'The current level of English of the user. From A1 to C2. No fictional levels.'
    },
    'goal_confirmed': {
      'type': 'boolean',
      'description':
          'Defaults to false. Set to true if the user explicitly confirmed their learning goal.'
    },
    'plan_confirmed': {
      'type': 'boolean',
      'description':
          'Defaults to false. Set to true if the user explicitly confirmed their learning plan.'
    }
  },
  'required': [
    'name',
    'native_language',
    'reason_to_learn_english',
    'interests',
    'current_level_of_english',
    'goal_confirmed',
    'plan_confirmed'
  ]
};
