import 'package:dio/dio.dart';
import 'package:flutter_app/bean/article.dart';
import 'package:flutter_app/bean/celebrity.dart';
import 'package:flutter_app/bean/news.dart';
import 'package:flutter_app/bean/now.dart';
import 'package:flutter_app/bean/photos.dart';
import 'package:flutter_app/bean/poetry.dart';
import 'package:flutter_app/bean/reviews.dart';
import 'package:flutter_app/bean/movie.dart';
import 'package:flutter_app/bean/result.dart';
import 'package:flutter_app/global/config.dart';
import 'package:flutter_app/utils/http_utils.dart';
import 'package:flutter_app/utils/log_util.dart';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class ApiService {
  static final String MOVIE_LIST_URL = "/in_theaters";
  static final String MOVIE_DETAIL_URL = "/subject";
  static final String MOVIE_TOP250_URL = "/top250";
  static final String MOVIE_SEARCH_URL = "/search";
  static final String MOVIE_SOON_URL = "/coming_soon";

  static final String NEW_MOVIES_URL = "/new_movies";

  static final String WEEKLY_MOVIES_URL = "/weekly";

  static final String US_MOVIES_URL = "/us_box";

  static final String ARTICLE_BASE_URL = "https://interface.meiriyiwen.com";

  static final String ARTICLE_TODAY_URL = ARTICLE_BASE_URL + "/article/today";
  static final String ARTICLE_DAY_URL = ARTICLE_BASE_URL + "/article/day";
  static final String ARTICLE_RANDOM_URL = ARTICLE_BASE_URL + "/article/random";

  static final String RECOMMEND_POETRY =
      'https://api.apiopen.top/recommendPoetry';

  static final String WEATHER_BASE_URL = "https://free-api.heweather.net/s6/";

  static final String WEATHER = WEATHER_BASE_URL + "weather";

  static final String CITY_TOP = "https://search.heweather.net/top";

  /// 获取首页热门新闻文章
  static Future<List<News>> getNewsList() async {
    List<News> news = [];

    await http.get(Config.DOUBAN_WEB_URL).then((http.Response response) {
      var document = parse(response.body.toString());
      List<dom.Element> items =
          document.getElementsByClassName('gallery-frame');
      items.forEach((item) {
        String cover =
            item.getElementsByTagName('img')[0].attributes['src'].toString();
        String link =
            item.getElementsByTagName('a')[0].attributes['href'].toString();
        String title =
            item.getElementsByTagName('h3')[0].text.toString().trim();
        String summary =
            item.getElementsByTagName('p')[0].text.toString().trim();
        News movieNews = News(title, cover, summary, link);
        news.add(movieNews);
      });
    });

    LogUtil.v(news.toString());

    return news;
  }

  /// 获取正在上映电影
  static Future<List<Movie>> getNowPlayingList(
      {String city, int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(MOVIE_LIST_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'city': city,
      'start': start,
      'count': count,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 获取即将上映电影
  static Future<List<Movie>> getComingList(
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(MOVIE_SOON_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      "start": start,
      'count': count,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 获取排行榜电影
  static Future<List<Movie>> getRankingList(String url,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(url, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'start': start,
      'count': count,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 获取本周口碑榜电影
  static Future<List<Movie>> getWeeklyList() async {
    Response response = await HttpUtils().get(WEEKLY_MOVIES_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    List<Movie> movies = [];
    result.subjects.map((m) {
      movies.add(m.subject);
    }).toList();

    return movies;
  }

  /// 获取新片榜电影
  static Future<List<Movie>> getNewMoviesList() async {
    Response response = await HttpUtils().get(NEW_MOVIES_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 获取北美票房榜电影
  static Future<List<Movie>> getUsBoxList() async {
    Response response = await HttpUtils().get(US_MOVIES_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    List<Movie> movies = [];
    result.subjects.map((m) {
      movies.add(m.subject);
    }).toList();

    return movies;
  }

  /// 获取 top250 榜单
  static Future<List<Movie>> getTop250List(
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(MOVIE_TOP250_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'start': start,
      'count': count
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 根据标签搜索
  static Future<List<Movie>> getSearchListByTag(
      {String tag, int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(MOVIE_SEARCH_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'tag': tag,
      'start': start,
      'count': count
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 根据关键字搜索
  static Future<List<Movie>> getSearchListByKey(
      {String key, int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(MOVIE_SEARCH_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'q': key,
      'start': start,
      'count': count
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 搜索电影
  static Future<List<Movie>> getSearchList(
      {String key, String tag, int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get(MOVIE_SEARCH_URL, data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'q': key,
      'tag': tag,
      'start': start,
      'count': count
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);

    return result.subjects;
  }

  /// 获取电影详情
  static Future<Movie> getMovieDetail(String movieId) async {
    Response response = await HttpUtils().get('/subject/$movieId', data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
    });
    if (response.statusCode != 200) {
      return null;
    }
    return Movie.fromMap(response.data);
  }

  /// 影片剧照
  static Future<List<Photos>> getMovieAlbum(String movieId,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get('/subject/$movieId/photos',
        data: {
          'apikey': Config.DOUBAN_MOVIE_KEY,
          'start': start,
          'count': count
        });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.photos;
  }

  /// 影人详细信息
  static Future<Celebrity> getActorDetail(String actorId) async {
    Response response = await HttpUtils().get('/celebrity/$actorId', data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
    });
    if (response.statusCode != 200) {
      return null;
    }
    return Celebrity.fromMap(response.data);
  }

  /// 影人相片
  static Future<List<Photos>> getActorPhotos(String actorId,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get('/celebrity/$actorId/photos',
        data: {
          'apikey': Config.DOUBAN_MOVIE_KEY,
          'start': start,
          'count': count
        });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.photos;
  }

  /// 剧照
  static Future<List<Photos>> getPhotos(String url, String id,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get('/$url/$id/photos', data: {
      'apikey': Config.DOUBAN_MOVIE_KEY,
      'start': start,
      'count': count
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.photos;
  }

  /// 影人作品
  static Future<List<Movie>> getActorMovies(String actorId,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get('/celebrity/$actorId/works',
        data: {
          'apikey': Config.DOUBAN_MOVIE_KEY,
          'start': start,
          'count': count
        });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    List<Movie> movies = [];
    result.works.map((work) {
      movies.add(work.subject);
    }).toList();
    return movies;
  }

  /// 短评
  static Future<List<Reviews>> getComments(String movieId,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get('/subject/$movieId/comments',
        data: {
          'apikey': Config.DOUBAN_MOVIE_KEY,
          'start': start,
          'count': count
        });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.comments;
  }

  /// 影评
  static Future<List<Reviews>> getReviews(String movieId,
      {int start = 0, int count = 20}) async {
    Response response = await HttpUtils().get('/subject/$movieId/reviews',
        data: {
          'apikey': Config.DOUBAN_MOVIE_KEY,
          'start': start,
          'count': count
        });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.reviews;
  }

  /// 每日一文
  static Future<Article> getTodayArticle() async {
    Response response =
        await HttpUtils().get(ARTICLE_TODAY_URL, data: {'dev': 1});
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.article;
  }

  /// 特定日期文章
  static Future<Article> getDayArticle(String date) async {
    Response response = await HttpUtils()
        .get(ARTICLE_TODAY_URL, data: {'dev': 1, 'date': date});
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.article;
  }

  /// 随机文章
  static Future<Article> getRandomArticle(String date) async {
    Response response =
        await HttpUtils().get(ARTICLE_TODAY_URL, data: {'dev': 1});
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.article;
  }

  /// 随机诗词
  static Future<Poetry> getRecommendPoetry() async {
    Response response = await HttpUtils().get(RECOMMEND_POETRY, data: null);
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.poetry;
  }

  /// 得到当前天气
  static Future<NowBean> getHeWeatherNow(String city) async {
    Response response = await HttpUtils().get(WEATHER, data: {
      "location": city,
      "key": Config.HE_WEATHER_KEY,
    });
    if (response.statusCode != 200) {
      return null;
    }
    Result result = Result.fromMap(response.data);
    return result.heWeather[0].now;
  }
}