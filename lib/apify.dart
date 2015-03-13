library apify;

import "dart:async";

import "package:uri/uri.dart";

import "package:http/http.dart";
import "package:http/browser_client.dart";

class Node {
  final Client _client;
  final String path;
  Node(this._client, {this.path: ""});
  Future<Response> get() => _client.get(path);
  Future<Response> post([body]) => _client.post(path, body: body);
  Future<Response> put([body]) => _client.put(path, body: body);
  Future<Response> delete() => _client.delete(path);
}

class Template {
  final Client _client;
  final UriTemplate template;
  final Map<String, String> _boundData;
  Template(this._client, this.template, {data: null}) :
    _boundData = data != null ? new Map<String, String>.from(data) : <String, String>{};
  Template.fromString(Client client, String template, {data: null}) :
    this(client, new UriTemplate(template), data: data);
  Template bind(Map<String, String> data) {
    return new Template(_client, template, data: new Map<String, String>.from(_boundData)..addAll(data));
  }
  String _expand() {
    return template.expand(_boundData);
  }
  Node call(Map<String, String> data) {
    return new Node(_client, path: this.bind(data)._expand());
  }
}

class Apify {
  final Client _client;
  final String host;
  Apify({this.host: "/", client: null}) :
    _client = client != null ? client : new BrowserClient();
  Node path(String url) {
    return new Node(_client, path: host + url);
  }
  Template template(String template) {
    return new Template.fromString(_client, template);
  }
}
