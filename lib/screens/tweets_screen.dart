import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tweety_mobile/blocs/authentication/authentication_bloc.dart';
import 'package:tweety_mobile/blocs/notification/notification_bloc.dart';
import 'package:tweety_mobile/blocs/tweet/tweet_bloc.dart';
import 'package:tweety_mobile/models/tweet.dart';
import 'package:tweety_mobile/screens/tweet_wrapper.dart';
import 'package:tweety_mobile/widgets/avatar_button.dart';
import 'package:tweety_mobile/widgets/loading_indicator.dart';
import 'package:tweety_mobile/widgets/refresh.dart';
import 'package:tweety_mobile/widgets/tweet_card.dart';

class TweetsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  TweetsScreen({Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _TweetsScreenState createState() => _TweetsScreenState();
}

class _TweetsScreenState extends State<TweetsScreen> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  Completer<void> _tweetRefreshCompleter;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TweetBloc>(context).add(
      FetchTweet(),
    );
    BlocProvider.of<NotificationBloc>(context).add(
      FetchNotificationCounts(),
    );
    _scrollController.addListener(_onScroll);
    _tweetRefreshCompleter = Completer<void>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      BlocProvider.of<TweetBloc>(context).add(
        FetchTweet(),
      );
    }
  }

  List<Tweet> tweets = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: BlocListener<TweetBloc, TweetState>(
        listener: (context, state) {
          if (state is TweetLoaded) {
            _tweetRefreshCompleter?.complete();
            _tweetRefreshCompleter = Completer();
          }
        },
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          strokeWidth: 1.0,
          onRefresh: () {
            BlocProvider.of<TweetBloc>(context).add(
              RefreshTweet(),
            );
            return _tweetRefreshCompleter.future;
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 20.0,
                floating: true,
                iconTheme: IconThemeData(
                  color: Theme.of(context).cursorColor,
                ),
                leading: AvatarButton(
                  scaffoldKey: widget.scaffoldKey,
                ),
                title: Text(
                  'Tweety',
                  style: Theme.of(context).appBarTheme.textTheme.caption,
                ),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () =>
                        BlocProvider.of<AuthenticationBloc>(context).add(
                      AuthenticationLoggedOut(),
                    ),
                  )
                ],
              ),
              BlocBuilder<TweetBloc, TweetState>(
                builder: (context, state) {
                  if (state is TweetLoading) {
                    return SliverFillRemaining(
                      child: LoadingIndicator(),
                    );
                  }
                  if (state is TweetLoaded) {
                    tweets = state.tweets;
                    if (state.tweets.isEmpty) {
                      return SliverFillRemaining(
                        child: Text(
                          'No tweets yet!',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => index >= tweets.length
                            ? LoadingIndicator()
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 5.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TweetWrapper(
                                          tweet: tweets[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: TweetCard(
                                    tweet: tweets[index],
                                    scaffoldKey: widget.scaffoldKey,
                                  ),
                                ),
                              ),
                        childCount: state.hasReachedMax
                            ? state.tweets.length
                            : state.tweets.length + 1,
                      ),
                    );
                  }
                  if (state is TweetError) {
                    return SliverToBoxAdapter(
                      child: Container(
                        child: Refresh(
                          title: 'Couldn\'t load feed',
                          onPressed: () {
                            BlocProvider.of<TweetBloc>(context).add(
                              RefreshTweet(),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return SliverFillRemaining(
                    child: LoadingIndicator(size: 21.0),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
