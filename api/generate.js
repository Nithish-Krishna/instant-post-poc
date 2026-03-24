export default async function handler(req, res) {
  // CORS setup
  res.setHeader('Access-Control-Allow-Credentials', true)
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT')
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, x-app-secret'
  )

  if (req.method === 'OPTIONS') {
    res.status(200).end()
    return
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' })
  }

  // Security Check: Require custom authorization header
  const appSecret = process.env.APP_SECRET;
  const receivedSecret = req.headers['x-app-secret'];

  if (!receivedSecret || receivedSecret !== appSecret) {
    return res.status(401).json({ error: 'Unauthorized: Invalid or missing x-app-secret header' });
  }

  try {
    const { prompt, tone, images } = req.body;

    if (!prompt || !images || !Array.isArray(images)) {
      return res.status(400).json({ error: 'Missing required fields: prompt, images' });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'GEMINI_API_KEY is not set' });
    }

    // ====================================================================
    // STEP 1: The Vision & Planning Phase (gemini-1.5-flash)
    // ====================================================================

    const planningParts = [
      {
        text: `You are an expert social media art director. Analyze the attached images.
        User Prompt: "${prompt}"
        Tone: "${tone}"
        
        Your job is to plan the perfect Instagram post. You must return exactly ONE valid JSON object with these three keys:
        1. "imagePrompt": Write a highly detailed, descriptive prompt for a 4:5 vertical Instagram post that will be fed to an image generator to composite these items together. Include lighting, aesthetic, and instructions to overlay the user's text matching the tone.
        2. "caption": An engaging Instagram caption matching the tone, with emojis and hashtags.
        3. "musicChoice": A trending song name and artist that fits the vibe.`
      }
    ];

    // Add the user's images for the vision model to analyze
    for (const base64Image of images) {
      const base64Data = base64Image.replace(/^data:image\/\w+;base64,/, '');
      planningParts.push({ inlineData: { mimeType: "image/jpeg", data: base64Data } });
    }

    const planResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: planningParts }],
        generationConfig: { responseMimeType: "application/json" } // Force JSON output
      })
    });

    if (!planResponse.ok) throw new Error(`Planning API Error: ${await planResponse.text()}`);
    const planData = await planResponse.json();

    // Parse the JSON from the vision model
    const planText = planData.candidates[0].content.parts[0].text.replace(/```json\n?|```/g, '').trim();
    const { imagePrompt, caption, musicChoice } = JSON.parse(planText);

    // ====================================================================
    // STEP 2: The Image Generation Phase (gemini-2.5-flash-image)
    // ====================================================================

    const imageParts = [
      { text: imagePrompt } // Pass the AI's optimized prompt
    ];

    // Pass the reference images to the image model so it knows what to composite
    for (const base64Image of images) {
      const base64Data = base64Image.replace(/^data:image\/\w+;base64,/, '');
      imageParts.push({ inlineData: { mimeType: "image/jpeg", data: base64Data } });
    }

    const imageResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${apiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: imageParts }],
        generationConfig: { 
          responseModalities: ["IMAGE"],
          imageConfig: {
            aspectRatio: "4:5"
          }
        } // Strictly request pixels
      })
    });

    if (!imageResponse.ok) throw new Error(`Image API Error: ${await imageResponse.text()}`);
    const imageData = await imageResponse.json();

    // Extract the raw Base64 string from the response
    const generatedImage = imageData.candidates[0].content.parts[0].inlineData.data;

    if (!generatedImage) throw new Error('Gemini API did not return image data.');

    // ====================================================================
    // STEP 3: Return the final package to Flutter
    // ====================================================================

    return res.status(200).json({
      generatedImage,
      caption,
      musicChoice
    });

  } catch (error) {
    console.error('Error in /api/generate:', error);
    return res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
}