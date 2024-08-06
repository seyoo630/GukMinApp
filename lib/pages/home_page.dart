import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  bool isFirstMessage = true;

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "KB 알뜰비서",
      profileImage:
      "https://cdn.imweb.me/upload/S202406060cf2b310a990f/54dfb3e3ad098.png");

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    String currentDate = DateFormat('- yyyy. M. d EEEE -', 'ko_KR').format(DateTime.now());
    messages = [
      ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: '',
        customProperties: {"type": "banner"},
      ),
      ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "어떤 업무를 도와드리면 될까요?",
        customProperties: {"type": "welcome"},
      ),

      ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "김신입님, 안녕하세요.\nKB국민은행 알뜰비서입니다.",
        customProperties: {"type": "welcome"},
        medias: [
          ChatMedia(
            url: 'https://cdn.imweb.me/upload/S202406060cf2b310a990f/de76afa4ebedd.png',
            fileName: "",
            type: MediaType.image,
          )
        ],
      ),

      ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: currentDate,
          customProperties: {"type": "date"}
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF736656),
        centerTitle: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "챗봇 / 알뜰비서",
            style: TextStyle(fontSize: 16, color: Colors.white),  // 글자 크기 줄이기, 글자 색 변경
          ),
        ),
        toolbarHeight: 46.0, // 높이 크기 20px 줄이기
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            color: const Color(0xFFFDF7E7),  // 배경색 변경
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF736656),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),  // 버튼 크기 변경
                ),
                child: const Text(
                  "광고 배너",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildUI(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF7E7),  // 배경색 변경
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(
              Icons.image,
            ),
          ),
        ],
        inputDecoration: const InputDecoration(
          hintText: '메시지를 입력하세요...',
          filled: true,
          fillColor: Colors.white,  // 하단 입력 배경을 흰색으로
        ),
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(
        messageDecorationBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
          if (message.customProperties?["type"] == "date") {
            return BoxDecoration(
              color: Colors.transparent,
            );
          } else if (message.customProperties?["type"] == "welcome") {
            return BoxDecoration(
              color: Colors.transparent,
            );
          } else {
            return BoxDecoration(
              color: const Color(0xFF736656),
              borderRadius: BorderRadius.circular(8),
            );
          }
        },
        messageRowBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage, bool isAfterDateSeparator, bool isBeforeDateSeparator) {
          if (message.customProperties?["type"] == "date") {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  message.text!,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
            );
          } else if (message.customProperties?["type"] == "welcome") {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.medias != null)
                    Image.network(
                      message.medias!.first.url,
                      height: 50,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.text!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }  else if (message.customProperties?["type"] == "banner") {
            return _buildBanner();
          } else {
            return DefaultMessageBuilder(message: message);
          }
        },
      ),
    );
  }

  Widget _buildBanner() {
    List<Map<String, String>> bannerData = [
      {"title": "배너 1", "description": "첫 번째 이벤트 설명"},
      {"title": "배너 2", "description": "두 번째 이벤트 설명"},
      {"title": "배너 3", "description": "세 번째 이벤트 설명"},
      {"title": "배너 4", "description": "네 번째 이벤트 설명"},
      {"title": "배너 5", "description": "다섯 번째 이벤트 설명"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(bannerData.length, (index) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(48.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDC5C),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerData[index]["title"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bannerData[index]["description"]!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 수정된 함수: REST API 호출
  Future<String> fetchResponse(String question, {List<Uint8List>? images}) async {
    const String apiUrl = 'YOUR_REST_API_ENDPOINT';  // REST API 엔드포인트 URL
    const String revenuePredictionApiUrl = 'YOUR_REVENUE_PREDICTION_API_ENDPOINT';  // 수익 예측 API 엔드포인트 URL

    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {
      "question": question,
      "images": images?.map((img) => base64Encode(img)).toList(),
    };

    String endpoint = apiUrl;

    // 질문이 '다음달 수익금'과 관련된 경우 예측 API 엔드포인트를 사용
    if (question.contains("다음달 수익금")) {
      endpoint = revenuePredictionApiUrl;
    }

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('answer')) {
        return jsonResponse['answer'];  // API 응답에서 답변 추출
      } else if (jsonResponse.containsKey('predicted_revenue')) {
        // 수익금 예측 결과를 반환
        return '다음달 예상 수익금은 ${jsonResponse['predicted_revenue']}원 입니다.';
      } else {
        return '죄송합니다, 처리할 수 없는 질문입니다.';  // 기본 응답
      }
    } else {
      return '죄송합니다, 처리할 수 없는 질문입니다.';  // 기본 응답
    }
  }

  // 이미지 처리 함수 (로컬에서 처리)
  Future<String> processImageLocally(Uint8List image) async {
    final inputImage = InputImage.fromFilePath(File.fromRawPath(image).path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String extractedText = recognizedText.text;
    textRecognizer.close();

    return '이미지에 대한 분석 결과입니다.\n텍스트: $extractedText';
  }

  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];

        // 이미지가 포함된 경우 로컬에서 처리
        String response = await processImageLocally(images.first);

        ChatMessage message = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          messages = [message, ...messages];
        });
      } else {
        // 텍스트 질문의 경우 REST API 호출
        String response = await fetchResponse(question);

        ChatMessage message = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          messages = [message, ...messages];
        });
      }
    } catch (e) {
      print(e);
      ChatMessage message = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: '죄송합니다, 처리할 수 없는 질문입니다.',
      );
      setState(() {
        messages = [message, ...messages];
      });
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}

class DefaultMessageBuilder extends StatelessWidget {
  final ChatMessage message;

  const DefaultMessageBuilder({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.user.id == "0" ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (message.user.id != "0")
          CircleAvatar(
            backgroundImage: NetworkImage(message.user.profileImage ?? ''),
          ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0x10523517),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.text != null)
                Text(
                  message.text!,
                  style: TextStyle(color: message.user.id == "0" ? Colors.black : Colors.black),
                ),
              if (message.medias != null && message.medias!.isNotEmpty)
                Image.file(
                  File(message.medias!.first.url),
                  height: 150,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ],
    );
  }
}