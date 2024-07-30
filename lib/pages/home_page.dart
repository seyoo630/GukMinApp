import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "신입봇",
      profileImage:
      "https://seeklogo.com/images/U/umizoomi-bot-logo-0982C669D8-seeklogo.com.png");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBDDCC),
        centerTitle: false,
        title: const Text(
          "Sinyip Chat",
        ),
      ),
      body: _buildUI(),
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
        ),
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  // 추가된 함수: REST API 호출
  Future<String> fetchResponse(String question, {List<Uint8List>? images}) async {
    const String apiUrl = 'YOUR_REST_API_ENDPOINT';  // REST API 엔드포인트 URL

    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {
      "question": question,
      "images": images?.map((img) => base64Encode(img)).toList(),
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('answer')) {
        return jsonResponse['answer'];  // API 응답에서 답변 추출
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
