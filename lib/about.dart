import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TechFusionApp extends StatelessWidget {
  const TechFusionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechFusion',
      theme: ThemeData(
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: AboutUsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AboutUsPage extends StatelessWidget {
  final String aboutUsContent = '''
**About Us**

Welcome to **TechFusion**, where your vision for the perfect PC comes to life. We're passionate about empowering you to create a computer that's not just a machine but an extension of who you are.

Born from a love of innovation and a desire to simplify the PC-building journey, we've crafted an app that puts the power in your hands. No more wading through endless webpages or second-guessing compatibility—just pure, unbridled customization at your fingertips.

Our platform is all about choice and ease. Dive into our extensive catalog of the latest and greatest computer parts. Mix and match components, experiment with different builds, and see your creation come together in real-time. With our smart compatibility checks, you can build with confidence, knowing every piece fits perfectly.

Built using the cutting-edge Flutter framework and Dart language, our app delivers a sleek and seamless experience, whether you're on your couch or on the go. We believe technology should adapt to you, not the other way around.

But we're more than just an app—we're a community of tech enthusiasts, gamers, creators, and innovators. Join us in sharing builds, swapping tips, and pushing the boundaries of what's possible. Your creativity fuels us, and together, we're redefining the PC-building experience.

Ready to embark on your custom PC journey? Let's build something amazing together.

**Contact Us**

If you have any questions, suggestions, or need support, feel free to reach out to us:

- **Email**: support@techfusion.com
- **Phone**: +1-800-123-4567
- **Address**: 123 Tech Street, Innovation City, Techland

We look forward to hearing from you!

**Follow Us**

Stay connected with us on social media for the latest updates, tips, and exclusive offers:
- **Facebook**: TechFusion
- **Twitter**: @TechFusion
- **Instagram**: @TechFusion
''';

  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: aboutUsContent,
                styleSheet: MarkdownStyleSheet(
                  h2: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  p: const TextStyle(fontSize: 18.0, height: 1.5),
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'support@techfusion.com',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '+1-800-123-4567',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '123 Tech Street, Innovation City, Techland',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.facebook, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Facebook: TechFusion',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.alternate_email, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Twitter: @TechFusion',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Instagram: @TechFusion',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}