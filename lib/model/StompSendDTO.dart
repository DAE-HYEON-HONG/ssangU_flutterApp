class StompSendDTO {
  String orderId;
  String sender;
  String content;
  String type;
  String createAt;

  StompSendDTO({this.orderId, this.sender, this.content, this.type, this.createAt});

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'sender': sender,
        'content': content,
        'type': type,
      };

  StompSendDTO.fromJson(Map<String, dynamic> json)
      : orderId = json['orderId'],
        sender = json['sender'],
        content = json['content'],
        type = json['type'],
        createAt = json['createDate'];
}
