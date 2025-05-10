import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = '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'; // Replace with your OpenAI API key

  // Helper function to normalize text input
  String normalizeText(String text) {
    return text.trim().toLowerCase();
  }

  // Function to compare pet descriptions with more detailed context
  Future<Map<String, dynamic>> matchPetDescriptions(
      String lostName,
      String lostBreed,
      String lostColor,
      String lostLocation,
      String foundName,
      String foundBreed,
      String foundColor,
      String foundLocation) async {
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    // Normalize the text fields
    lostName = normalizeText(lostName);
    lostBreed = normalizeText(lostBreed);
    lostColor = normalizeText(lostColor);
    lostLocation = normalizeText(lostLocation);

    foundName = normalizeText(foundName);
    foundBreed = normalizeText(foundBreed);
    foundColor = normalizeText(foundColor);
    foundLocation = normalizeText(foundLocation);

    // Constructing the input for OpenAI with more detailed context
    final Map<String, dynamic> requestBody = {
      "model": "gpt-4",
      "messages": [
        {
          "role": "system",
          "content":
          "You are a pet matching assistant. Your task is to compare the descriptions of a lost pet and a found pet."
              " Please analyze and provide a similarity score between 0 and 100% based on various factors, including but not limited to:"
              " name, breed, color, size, age, any distinguishing marks or features, and location."
              " Consider the following factors for comparison:"
              "1. **Name**: How closely do the names of the pets match?"
              "2. **Breed**: Is the breed a direct match, or are there similarities in the breed family?"
              "3. **Color**: How similar are the color descriptions? Consider possible shades or variations."
              "4. **Location**: Is the location of the lost pet and found pet in the same or similar areas? Consider proximity and likelihood of the pet being in the location."
              "5. **Size**: Are there any descriptions of size (e.g., small, medium, large)? How well do the sizes compare?"
              "6. **Age**: If age is mentioned, compare the estimated age of both pets."
              "7. **Distinguishing Features**: Look for any distinctive marks, like scars, spots, or special characteristics that could help with the match."
              "Provide a detailed analysis of the lost and found pets' descriptions. If there are any differences in characteristics such as breed, color, or location, please point them out. "
              "Also, explain how the descriptions may be similar, despite potential differences. Ensure that you are considering all available information and make sure to explain your reasoning for the similarity score."
        },
        {"role": "user", "content": "Lost Pet Name: $lostName"},
        {"role": "user", "content": "Lost Pet Breed: $lostBreed"},
        {"role": "user", "content": "Lost Pet Color: $lostColor"},
        {"role": "user", "content": "Lost Pet Location: $lostLocation"},
        {"role": "user", "content": "Found Pet Name: $foundName"},
        {"role": "user", "content": "Found Pet Breed: $foundBreed"},
        {"role": "user", "content": "Found Pet Color: $foundColor"},
        {"role": "user", "content": "Found Pet Location: $foundLocation"},
      ],
      "temperature": 0.7,
      "max_tokens": 300,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "similarityScore": extractScore(data["choices"][0]["message"]["content"]),
        "explanation": data["choices"][0]["message"]["content"],
      };
    } else {
      throw Exception("Failed to get response: ${response.body}");
    }
  }

  // Helper function to extract the similarity score from the response
  int extractScore(String responseText) {
    final match = RegExp(r'(\d{1,3})%').firstMatch(responseText);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  // Function to calculate location proximity based on basic string matching (you can later replace this with actual geolocation comparison)
  bool isLocationClose(String lostLocation, String foundLocation) {
    // Check if both locations match directly or are related (you can expand this logic further if needed)
    return lostLocation == foundLocation;
  }
}
