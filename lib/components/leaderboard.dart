library leaderboard;

import 'package:dispatch/dispatch.dart';
import 'package:github/common.dart';
import 'package:react/react.dart' as react;
import 'package:issues_leaderboard/actions.dart' as actions;
import 'package:issues_leaderboard/stores/leaderboard_store.dart';
import 'package:issues_leaderboard/util/react/css_transition_group.dart';

class _Leaderboard extends react.Component {
  getInitialState() => {'positions': []};
  
  DispatchWatcher _watcher;
  componentWillMount() {
    _watcher = _dispatcher.watch((action) {
      switch (action['message']) {
        case actions.STORE_CHANGE:
          if (action['data'] is LeaderboardStore)
            setState({'positions': leaderboardStore.positions});
          break;
      }
    });
  }
  
  componentWillUnmount() {
    _watcher.destroy();
  }
  
  render() {
    return react.div({'className': 'leaderboard'}, [
      _renderTitle(),
      CSSTransitionGroup({'transitionName': 'player', 'key': 'players'},
        _renderPositions())
    ]);
  }
  
  _renderTitle() {
    return react.table({'key': 'title'}, [
      react.tr({}, [
        react.td({'key': 'gun1'}, react.img({'src': '/images/gun.png', 'className': 'gun gun-1'})),
        react.td({'key': 'title'}, react.h1({'key': 'title'}, 'OrgSync Bug Shootout')),
        react.td({'key': 'gun2'}, react.img({'src': '/images/gun.png', 'className': 'gun gun-2'}))
      ])
    ]);
  }
  
  _renderPositions() {
    var lastPosition;
    
    return _positions.take(5)
      .map((position) {
        var isDuel = lastPosition != null && lastPosition.rank == position.rank;
        lastPosition = position;
        
        var avatarCell = [react.img({'src': position.player.user.avatarUrl, 'className': 'avatar'})];
        if (position.rank == 1)
          avatarCell.add(react.img({'key': 'sheriff', 'src': '/images/sheriff.png', 'className': 'sheriff'}));
        if (isDuel)
          avatarCell.add(react.div({'key': 'duel', 'className': 'deul'}, 'Duel'));
        
        return react.table({'key': position.player.user.id},  
          react.tr({}, [
            react.td({'key': 'place', 'width': '5%'}, position.rank),
            react.td({'key': 'avatar', 'width': '10%'}, avatarCell),
            react.td({'key': 'points', 'width': '60%'},
              CSSTransitionGroup({'transitionName': 'point'},
                _renderIssues(position.player.issues))),
            react.td({'key': 'total', 'width': '25%', 'className': 'total'},
                '${position.player.points} ${position.player.points == 1 ? 'point' : 'points'}')
          ])
        );
      });
  }

  _renderIssues(List<Issue> issues) {
    var key = 0;
    return issues.map((issue) {
      var rotation = issue.number % 9 - 4;
      var style = {
        'background-color': _colorForIssue(issue),
        'transform': 'rotate(${rotation}deg)'
      };
      return react.div({'key': key++, 'className': 'point', 'style': style}, [
        react.div({'key': 'tint', 'className': 'tint'}),
        react.span({'key': 'points'}, pointsForIssue(issue))
      ]);
    });
  }
  
  Dispatch get _dispatcher => props['dispatcher'];
  
  List<Position> get _positions => state['positions'];
}

String _colorForIssue(Issue issue) {
  var points = pointsForIssue(issue);
  var label = issue.labels.firstWhere((label) => label.name == points.toString());
  return label != null ? '#${label.color}' : 'rgb(88, 51, 27)';
}

var Leaderboard = react.registerComponent(() => new _Leaderboard());