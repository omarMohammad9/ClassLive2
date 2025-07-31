import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../BottomNavigation/bottomNavigation.dart';

// Models
class Quiz {
  final String id;
  final String subject;
  final DateTime date;
  final int questionCount;
  final int timeInMinutes;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.subject,
    required this.date,
    required this.questionCount,
    required this.timeInMinutes,
    required this.questions,
  });
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
  });
}

class QuizAnswer {
  final String questionId;
  final int selectedAnswer;

  QuizAnswer({
    required this.questionId,
    required this.selectedAnswer,
  });
}

// Sample Data
class QuizData {
  static List<Quiz> getQuizzes() {
    return [
      Quiz(
        id: '1',
        subject: 'Mathematics',
        date: DateTime.now().subtract(const Duration(days: 1)),
        questionCount: 4,
        timeInMinutes: 10,
        questions: [
          Question(
            id: '1',
            text: 'What is 2 + 2?',
            options: ['3', '4', '5', '6'],
            correctAnswer: 1,
          ),
          Question(
            id: '2',
            text: 'What is the square root of 16?',
            options: ['2', '3', '4', '5'],
            correctAnswer: 2,
          ),
          Question(
            id: '3',
            text: 'What is 10 × 5?',
            options: ['45', '50', '55', '60'],
            correctAnswer: 1,
          ),
          Question(
            id: '4',
            text: 'What is 100 ÷ 4?',
            options: ['20', '25', '30', '35'],
            correctAnswer: 1,
          ),
        ],
      ),
      Quiz(
        id: '2',
        subject: 'Science',
        date: DateTime.now().subtract(const Duration(days: 2)),
        questionCount: 4,
        timeInMinutes: 10,
        questions: [
          Question(
            id: '1',
            text: 'What is the chemical symbol for water?',
            options: ['H2O', 'CO2', 'NaCl', 'O2'],
            correctAnswer: 0,
          ),
          Question(
            id: '2',
            text: 'Which planet is closest to the Sun?',
            options: ['Venus', 'Earth', 'Mercury', 'Mars'],
            correctAnswer: 2,
          ),
          Question(
            id: '3',
            text: 'What gas do plants absorb from the atmosphere?',
            options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
            correctAnswer: 2,
          ),
          Question(
            id: '4',
            text: 'How many bones are in an adult human body?',
            options: ['196', '206', '216', '226'],
            correctAnswer: 1,
          ),
        ],
      ),
      Quiz(
        id: '3',
        subject: 'History',
        date: DateTime.now().subtract(const Duration(days: 3)),
        questionCount: 4,
        timeInMinutes: 10,
        questions: [
          Question(
            id: '1',
            text: 'In which year did World War II end?',
            options: ['1944', '1945', '1946', '1947'],
            correctAnswer: 1,
          ),
          Question(
            id: '2',
            text: 'Who was the first President of the United States?',
            options: [
              'Thomas Jefferson',
              'John Adams',
              'George Washington',
              'Benjamin Franklin'
            ],
            correctAnswer: 2,
          ),
          Question(
            id: '3',
            text: 'Which ancient wonder was located in Alexandria?',
            options: [
              'Colossus of Rhodes',
              'Lighthouse of Alexandria',
              'Hanging Gardens',
              'Statue of Zeus'
            ],
            correctAnswer: 1,
          ),
          Question(
            id: '4',
            text: 'The Renaissance began in which country?',
            options: ['France', 'Germany', 'Italy', 'Spain'],
            correctAnswer: 2,
          ),
        ],
      ),
    ];
  }
}

class Quizzes extends StatelessWidget {
  const Quizzes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizzes = QuizData.getQuizzes();

    return Scaffold(
      extendBody: true,
      drawer: Drawer(
        width: 240,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF1A4C9C),
              ),
              padding: EdgeInsets.only(left: 16, bottom: 16),
              alignment: Alignment.bottomLeft,
              child: Row(mainAxisAlignment:MainAxisAlignment.center ,
                children: [
                  SizedBox(width:5 ,),
                  Text(
                    'اختر المادة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: Icon(Icons.book, color: Color(0xFF1A4C9C)),
                    title: Text('الرياضيات', style: TextStyle(fontSize: 16)),
                    onTap: () => Navigator.pop(context),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.science, color: Color(0xFF1A4C9C)),
                    title: Text('العلوم', style: TextStyle(fontSize: 16)),
                    onTap: () => Navigator.pop(context),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.language, color: Color(0xFF1A4C9C)),
                    title: Text('اللغة الإنجليزية', style: TextStyle(fontSize: 16)),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),


      appBar: AppBar(
        centerTitle:true ,
        iconTheme:IconThemeData(color:Colors.white ) ,
        title: Text(
          'Quizzes'.tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1A4C9C),
      ),

      backgroundColor: Colors.transparent,
      // شفافية الخلفية
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BottomNavigation(selectedIndex: 3),
        ),
      ),
      body: Stack(
        children: [


          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A4C9C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.assignment,
                                color: Color(0xFF1A4C9C),
                                size: 28,
                              ),
                            ),
                            title: Text(
                              quiz.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A4C9C),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${_formatDate(quiz.date)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${quiz.questionCount} questions • ${quiz.timeInMinutes} minutes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF1A4C9C),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizStartPage(quiz: quiz),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// 2. Quiz Start Page
class QuizStartPage extends StatelessWidget {
  final Quiz quiz;

  const QuizStartPage({Key? key, required this.quiz}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quizzes".tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1A4C9C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.quiz,
                size: 60,
                color: Color(0xFF1A4C9C),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              quiz.subject,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A4C9C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
                'Number of Questions', '${quiz.questionCount} questions'),
            const SizedBox(height: 16),
            _buildInfoCard('Time Allocated', '${quiz.timeInMinutes} minutes'),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionsPage(quiz: quiz),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4C9C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Start Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1A4C9C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A4C9C),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Quiz Questions Page
class QuizQuestionsPage extends StatefulWidget {
  final Quiz quiz;

  const QuizQuestionsPage({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0;
  List<QuizAnswer> answers = [];
  int? selectedAnswer;
  late Timer timer;
  late int remainingSeconds;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.quiz.timeInMinutes * 60;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          timer.cancel();
          _finishQuiz();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _nextQuestion() {
    if (selectedAnswer != null) {
      // Save the answer
      final existingAnswerIndex = answers.indexWhere(
        (answer) =>
            answer.questionId == widget.quiz.questions[currentQuestionIndex].id,
      );

      if (existingAnswerIndex >= 0) {
        answers[existingAnswerIndex] = QuizAnswer(
          questionId: widget.quiz.questions[currentQuestionIndex].id,
          selectedAnswer: selectedAnswer!,
        );
      } else {
        answers.add(QuizAnswer(
          questionId: widget.quiz.questions[currentQuestionIndex].id,
          selectedAnswer: selectedAnswer!,
        ));
      }

      if (currentQuestionIndex < widget.quiz.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          // Check if we have a saved answer for this question
          final savedAnswer = answers.firstWhere(
            (answer) =>
                answer.questionId ==
                widget.quiz.questions[currentQuestionIndex].id,
            orElse: () => QuizAnswer(questionId: '', selectedAnswer: -1),
          );
          selectedAnswer = savedAnswer.selectedAnswer >= 0
              ? savedAnswer.selectedAnswer
              : null;
        });
      }
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        // Load the saved answer for this question
        final savedAnswer = answers.firstWhere(
          (answer) =>
              answer.questionId ==
              widget.quiz.questions[currentQuestionIndex].id,
          orElse: () => QuizAnswer(questionId: '', selectedAnswer: -1),
        );
        selectedAnswer =
            savedAnswer.selectedAnswer >= 0 ? savedAnswer.selectedAnswer : null;
      });
    }
  }

  void _finishQuiz() {
    timer.cancel();

    // Save current answer if any
    if (selectedAnswer != null) {
      final existingAnswerIndex = answers.indexWhere(
        (answer) =>
            answer.questionId == widget.quiz.questions[currentQuestionIndex].id,
      );

      if (existingAnswerIndex >= 0) {
        answers[existingAnswerIndex] = QuizAnswer(
          questionId: widget.quiz.questions[currentQuestionIndex].id,
          selectedAnswer: selectedAnswer!,
        );
      } else {
        answers.add(QuizAnswer(
          questionId: widget.quiz.questions[currentQuestionIndex].id,
          selectedAnswer: selectedAnswer!,
        ));
      }
    }

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final question = widget.quiz.questions[i];
      final userAnswer = answers.firstWhere(
        (answer) => answer.questionId == question.id,
        orElse: () => QuizAnswer(questionId: '', selectedAnswer: -1),
      );

      if (userAnswer.selectedAnswer == question.correctAnswer) {
        correctAnswers++;
      }
    }

    // Show results dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quiz Completed!',
          style: TextStyle(color: Color(0xFF1A4C9C)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              correctAnswers >= widget.quiz.questions.length / 2
                  ? Icons.celebration
                  : Icons.sentiment_neutral,
              size: 60,
              color: correctAnswers >= widget.quiz.questions.length / 2
                  ? Colors.green
                  : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $correctAnswers/${widget.quiz.questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Percentage: ${((correctAnswers / widget.quiz.questions.length) * 100).toInt()}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Back to Quizzes',
              style: TextStyle(color: Color(0xFF1A4C9C)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.subject),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4C9C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4C9C),
                    ),
                  ),
                  Text(
                    '${((currentQuestionIndex + 1) / widget.quiz.questions.length * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4C9C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF1A4C9C)),
              minHeight: 8,
            ),
            const SizedBox(height: 30),

            // Question
            Text(
              currentQuestion.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedAnswer == index
                            ? const Color(0xFF1A4C9C)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      color: selectedAnswer == index
                          ? const Color(0xFF1A4C9C).withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: RadioListTile<int>(
                      title: Text(
                        currentQuestion.options[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selectedAnswer == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedAnswer == index
                              ? const Color(0xFF1A4C9C)
                              : Colors.black87,
                        ),
                      ),
                      value: index,
                      groupValue: selectedAnswer,
                      activeColor: const Color(0xFF1A4C9C),
                      onChanged: (value) {
                        setState(() {
                          selectedAnswer = value;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1A4C9C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          color: Color(0xFF1A4C9C),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedAnswer != null
                        ? (currentQuestionIndex ==
                                widget.quiz.questions.length - 1
                            ? _finishQuiz
                            : _nextQuestion)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4C9C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      currentQuestionIndex == widget.quiz.questions.length - 1
                          ? 'Finish Quiz'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
