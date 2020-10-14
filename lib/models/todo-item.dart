import 'package:check_mk/models/model.dart';

class TodoService extends Model {


  static String table = 'todo_service';

  int id;
  String uid;
  int updatedate;
  String service_state ;
  String host;
  String service_description;
  String service_icons;
  String svc_plugin_output;
  String svc_state_age;
  String svc_check_age;
  String perfometer;
  int sort;
  int sorce;

  TodoService({ this.id, this.uid, this.updatedate, this.service_state, this.host,this.service_description, this.service_icons, this.svc_plugin_output, this.svc_state_age, this.svc_check_age, this.perfometer, this.sort, this.sorce  });

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      'uid': uid,
      'updatedate': updatedate,
      'service_state': service_state,
      'host': host,
      'service_description': service_description,
      'service_icons': service_icons,
      'svc_plugin_output': svc_plugin_output,
      'svc_state_age': svc_state_age,
      'svc_check_age': svc_check_age,
      'perfometer': perfometer,
      'sort' : sort,
      'sorce' : sorce,
    };

    if (id != null) { map['id'] = id; }
    return map;
  }

  static TodoService fromMap(Map<String, dynamic> map) {

    return TodoService(
        id: map['id'],
        uid: map['uid'],
        updatedate: map['updatedate'],
        service_state: map['service_state'],
        host: map['host'],
        service_description: map['service_description'],
        service_icons: map['service_icons'],
        svc_plugin_output: map['svc_plugin_output'],
        svc_state_age: map['svc_state_age'],
        svc_check_age: map['svc_check_age'],
        perfometer: map['perfometer'],
        sort: map['sort'],
      sorce: map['sorce'],
    );
  }
}



class TodoAllHost extends Model {


  static String table = 'todo_allhost';

  int id;
  String uid;
  int updatedate;
  String host_state ;
  String host;
  String host_icons;
  String num_services_ok;
  String num_services_warn;
  String num_services_unknown;
  String num_services_crit;
  String num_services_pending;
  int sort;
  int sorce;

  TodoAllHost({ this.id, this.uid, this.updatedate, this.host_state, this.host,this.host_icons, this.num_services_ok, this.num_services_warn, this.num_services_unknown, this.num_services_crit, this.num_services_pending,this.sort ,this.sorce  });

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      'uid': uid,
      'updatedate': updatedate,
      'host_state': host_state,
      'host': host,
      'host_icons': host_icons,
      'num_services_ok': num_services_ok,
      'num_services_warn': num_services_warn,
      'num_services_unknown': num_services_unknown,
      'num_services_crit': num_services_crit,
      'num_services_pending': num_services_pending,
      'sort': sort,
      'sorce': sorce,

    };

    if (id != null) { map['id'] = id; }
    return map;
  }

  static TodoAllHost fromMap(Map<String, dynamic> map) {

    return TodoAllHost(
      id: map['id'],
      uid: map['uid'],
      updatedate: map['updatedate'],
      host_state: map['host_state'],
      host: map['host'],
      host_icons: map['host_icons'],
      num_services_ok: map['num_services_ok'],
      num_services_warn: map['num_services_warn'],
      num_services_unknown: map['num_services_unknown'],
      num_services_crit: map['num_services_crit'],
      num_services_pending: map['num_services_pending'],
      sort: map['sort'],
      sorce: map['sorce'],
    );
  }
}








class TodoLastEvent extends Model {


  static String table = 'todo_lasevent';

  int id;
  String uid;
  int updatedate;
  String state ;
  String host;
  String service_description;
  String log_icon;
  String log_plugin_output;
  String log_time;
  int sort;
  int sorce;

  TodoLastEvent({ this.id, this.uid, this.updatedate, this.state, this.host,this.service_description, this.log_icon, this.log_plugin_output, this.log_time, this.sort, this.sorce  });

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      'uid': uid,
      'updatedate': updatedate,
      'state': state,
      'host': host,
      'service_description': service_description,
      'log_icon': log_icon,
      'log_plugin_output': log_plugin_output,
      'log_time': log_time,
      'sort' : sort,
      'sorce' : sorce,
    };

    if (id != null) { map['id'] = id; }
    return map;
  }

  static TodoLastEvent fromMap(Map<String, dynamic> map) {

    return TodoLastEvent(
      id: map['id'],
      uid: map['uid'],
      updatedate: map['updatedate'],
      state: map['state'],
      host: map['host'],
      service_description: map['service_description'],
      log_icon: map['log_icon'],
      log_plugin_output: map['log_plugin_output'],
      log_time: map['log_time'],
      sort: map['sort'],
      sorce: map['sorce'],
    );
  }
}










class SetupApp extends Model {


  static String table = 'setup_app';

  int ids;
  String url;
  String user ;
  String key;
  String user2 ;
  String key2;



  SetupApp({ this.ids,this.url, this.user,this.key, this.user2,this.key2 });

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      'url': url,
      'user': user,
      'key': key,
      'user2': user2,
      'key2': key2,
    };

    if (ids != null) { map['ids'] = ids; }
    return map;
  }

  static SetupApp fromMap(Map<String, dynamic> map) {

    return SetupApp(
      ids: map['ids'],
      url: map['url'],
      user: map['user'],
      key: map['key'],
      user2: map['user2'],
      key2: map['key2'],
    );
  }
}