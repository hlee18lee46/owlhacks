import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const {
      heartRate,
      breathingRate,
    } = body;

    if (heartRate == null || breathingRate == null) {
      return NextResponse.json(
        {
          error: "heartRate and breathingRate are required",
        },
        { status: 400 }
      );
    }

    const account = process.env.SNOWFLAKE_ACCOUNT;
    const token = process.env.SNOWFLAKE_PAT;

    if (!account || !token) {
      return NextResponse.json(
        {
          error: "Snowflake environment variables are not configured",
        },
        { status: 500 }
      );
    }

    const snowflakeUrl =
      `https://${account}.snowflakecomputing.com/api/v2/cortex/v1/chat/completions`;

    const snowflakeResponse = await fetch(snowflakeUrl, {
      method: "POST",

      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },

      body: JSON.stringify({
        model: "openai-gpt-5",

        messages: [
          {
            role: "system",
            content: `
You are the AI pet-matching engine for WhatTheHoot.

The user provides:
- heart rate
- breathing rate

Choose exactly one pet:
- OWL
- DUCK

Return ONLY valid JSON.

Format:
{
  "pet": "OWL",
  "mood": "Chill",
  "reason": "Short fun explanation"
}

Do not provide medical advice.
Do not diagnose the user.
            `.trim(),
          },

          {
            role: "user",
            content: `
Heart rate: ${heartRate} BPM
Breathing rate: ${breathingRate} breaths/min

Choose my WhatTheHoot companion.
            `.trim(),
          },
        ],
      }),
    });

    const raw = await snowflakeResponse.text();

    if (!snowflakeResponse.ok) {
      console.error("Snowflake Cortex error:", raw);

      return NextResponse.json(
        {
          error: "Snowflake Cortex request failed",
          status: snowflakeResponse.status,
          details: raw,
        },
        { status: 502 }
      );
    }

    const data = JSON.parse(raw);

    const content =
      data?.choices?.[0]?.message?.content;

    if (!content) {
      return NextResponse.json(
        {
          error: "Cortex returned no content",
          snowflakeResponse: data,
        },
        { status: 502 }
      );
    }

    /*
     * Cortex should return JSON because we explicitly
     * requested JSON in the system prompt.
     *
     * Remove ```json fences just in case.
     */
    const cleaned = content
      .replace(/```json/gi, "")
      .replace(/```/g, "")
      .trim();

    let recommendation;

    try {
      recommendation = JSON.parse(cleaned);
    } catch {
      recommendation = {
        pet: "OWL",
        mood: "Mysterious",
        reason: cleaned,
      };
    }

    return NextResponse.json({
      success: true,

      vitals: {
        heartRate,
        breathingRate,
      },

      recommendation,
    });
  } catch (error) {
    console.error("Cortex endpoint error:", error);

    return NextResponse.json(
      {
        error: "Internal server error",
        details:
          error instanceof Error
            ? error.message
            : "Unknown error",
      },
      { status: 500 }
    );
  }
}