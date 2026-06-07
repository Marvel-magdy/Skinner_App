import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../users/dashboard_user.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final PageController _controller =
      PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [

    {
      "image":
      "assets/one.png",

      "title":
      "Scan Your Skin in Seconds",

      "desc":
      "Take a quick skin scan and get AI-powered analysis with possible skin conditions and personalized recommendations."
    },

    {
      "image":
      "assets/two.png",

      "title":
      "Your AI Skin Assistant",

      "desc":
      "Chat with an intelligent dermatology assistant trained on skin conditions and receive a detailed report to share with your doctor."
    },

    {
      "image":
      "assets/three.png",

      "title":
      "Find the Right Dermatologist",

      "desc":
      "Explore nearby dermatologists, compare ratings and prices, and book appointments."
    },

  ];

  Future<void> finishOnboarding() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      "onboarding_seen",
      true,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const DashboardUser(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Column(

          children: [

            Padding(
              padding:
              const EdgeInsets.only(
                top: 10,
                right: 20,
              ),

              child: Align(
                alignment:
                Alignment.topRight,

                child: TextButton(

                  onPressed:
                  finishOnboarding,

                  child: const Text(

                    "Skip",

                    style: TextStyle(
                      color:
                      Color(0xFF7A63FF),

                      fontWeight:
                      FontWeight.w600,

                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(

              child: PageView.builder(

                controller:
                _controller,

                itemCount:
                pages.length,

                onPageChanged:
                    (index) {

                  setState(() {

                    currentPage =
                        index;

                  });
                },

                itemBuilder:
                    (context, index) {

                  return Padding(

                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 24,
                    ),

                    child: Column(

                      children: [

                        Expanded(

                          flex: 6,

                          child: Image.asset(

                            pages[index]
                            ["image"]!,

                            fit:
                            BoxFit.contain,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(

                          pages[index]
                          ["title"]!,

                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(

                            fontSize: 30,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Padding(

                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal:
                            12,
                          ),

                          child: Text(

                            pages[index]
                            ["desc"]!,

                            textAlign:
                            TextAlign.center,

                            style:
                            const TextStyle(

                              fontSize:
                              15,

                              height:
                              1.5,

                              color:
                              Colors
                                  .black54,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        Row(

                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                          children:
                          List.generate(

                            pages.length,

                                (i) => AnimatedContainer(

                              duration:
                              const Duration(
                                milliseconds:
                                300,
                              ),

                              margin:
                              const EdgeInsets
                                  .symmetric(
                                horizontal:
                                4,
                              ),

                              width:
                              currentPage ==
                                  i
                                  ? 24
                                  : 8,

                              height: 8,

                              decoration:
                              BoxDecoration(

                                color:
                                currentPage ==
                                    i
                                    ? const Color(
                                  0xFF2C67FF,
                                )
                                    : Colors
                                    .grey
                                    .shade300,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        SizedBox(

                          width: 170,
                          height: 55,

                          child:
                          ElevatedButton(

                            style:
                            ElevatedButton
                                .styleFrom(

                              backgroundColor:
                              const Color(
                                0xFF2C67FF,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                              ),

                              elevation:
                              0,
                            ),

                            onPressed:
                                () {

                              if (currentPage ==
                                  pages.length -
                                      1) {

                                finishOnboarding();

                              } else {

                                _controller
                                    .nextPage(

                                  duration:
                                  const Duration(
                                    milliseconds:
                                    300,
                                  ),

                                  curve:
                                  Curves
                                      .easeInOut,
                                );
                              }
                            },

                            child: Text(

                              currentPage ==
                                  pages.length -
                                      1

                                  ? "Get Started"

                                  : "Next",

                              style:
                              const TextStyle(

                                color:
                                Colors.white,

                                fontSize:
                                16,

                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 35,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}