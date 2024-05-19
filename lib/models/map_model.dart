import 'dart:convert';

MapModel mapModelFromJson(String str) => MapModel.fromJson(json.decode(str));

String mapModelToJson(MapModel data) => json.encode(data.toJson());

class MapModel {
  List<Result> results;

  MapModel({
    required this.results,
  });

  MapModel copyWith({
    List<Result>? results,
  }) =>
      MapModel(
        results: results ?? this.results,
      );

  factory MapModel.fromJson(Map<String, dynamic> json) => MapModel(
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class Result {
  Title title;
  Subtitle subtitle;
  List<String> tags;
  Distance distance;
  Address address;
  String uri;

  Result({
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.distance,
    required this.address,
    required this.uri,
  });

  Result copyWith({
    Title? title,
    Subtitle? subtitle,
    List<String>? tags,
    Distance? distance,
    Address? address,
    String? uri,
  }) =>
      Result(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        tags: tags ?? this.tags,
        distance: distance ?? this.distance,
        address: address ?? this.address,
        uri: uri ?? this.uri,
      );

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    title: Title.fromJson(json["title"]),
    subtitle: Subtitle.fromJson(json["subtitle"]),
    tags: List<String>.from(json["tags"].map((x) => x)),
    distance: Distance.fromJson(json["distance"]),
    address: Address.fromJson(json["address"]),
    uri: json["uri"],
  );

  Map<String, dynamic> toJson() => {
    "title": title.toJson(),
    "subtitle": subtitle.toJson(),
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "distance": distance.toJson(),
    "address": address.toJson(),
    "uri": uri,
  };
}

class Address {
  String formattedAddress;
  List<Component> component;

  Address({
    required this.formattedAddress,
    required this.component,
  });

  Address copyWith({
    String? formattedAddress,
    List<Component>? component,
  }) =>
      Address(
        formattedAddress: formattedAddress ?? this.formattedAddress,
        component: component ?? this.component,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    formattedAddress: json["formatted_address"],
    component: List<Component>.from(json["component"].map((x) => Component.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "formatted_address": formattedAddress,
    "component": List<dynamic>.from(component.map((x) => x.toJson())),
  };
}

class Component {
  String name;
  List<String> kind;

  Component({
    required this.name,
    required this.kind,
  });

  Component copyWith({
    String? name,
    List<String>? kind,
  }) =>
      Component(
        name: name ?? this.name,
        kind: kind ?? this.kind,
      );

  factory Component.fromJson(Map<String, dynamic> json) => Component(
    name: json["name"],
    kind: List<String>.from(json["kind"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "kind": List<dynamic>.from(kind.map((x) => x)),
  };
}

class Distance {
  String text;
  double value;

  Distance({
    required this.text,
    required this.value,
  });

  Distance copyWith({
    String? text,
    double? value,
  }) =>
      Distance(
        text: text ?? this.text,
        value: value ?? this.value,
      );

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
    text: json["text"],
    value: json["value"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "value": value,
  };
}

class Subtitle {
  String text;

  Subtitle({
    required this.text,
  });

  Subtitle copyWith({
    String? text,
  }) =>
      Subtitle(
        text: text ?? this.text,
      );

  factory Subtitle.fromJson(Map<String, dynamic> json) => Subtitle(
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
  };
}

class Title {
  String text;
  List<Hl> hl;

  Title({
    required this.text,
    required this.hl,
  });

  Title copyWith({
    String? text,
    List<Hl>? hl,
  }) =>
      Title(
        text: text ?? this.text,
        hl: hl ?? this.hl,
      );

  factory Title.fromJson(Map<String, dynamic> json) => Title(
    text: json["text"],
    hl: List<Hl>.from(json["hl"].map((x) => Hl.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "hl": List<dynamic>.from(hl.map((x) => x.toJson())),
  };
}

class Hl {
  int begin;
  int end;

  Hl({
    required this.begin,
    required this.end,
  });

  Hl copyWith({
    int? begin,
    int? end,
  }) =>
      Hl(
        begin: begin ?? this.begin,
        end: end ?? this.end,
      );

  factory Hl.fromJson(Map<String, dynamic> json) => Hl(
    begin: json["begin"],
    end: json["end"],
  );

  Map<String, dynamic> toJson() => {
    "begin": begin,
    "end": end,
  };
}
