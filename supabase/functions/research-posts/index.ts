import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const BRIGHTDATA_URL =
  "https://api.brightdata.com/datasets/v3/scrape?dataset_id=gd_l1vikfch901nx3by4&notify=false&include_errors=true&type=discover_new&discover_by=user_name";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
//GOT GIT GGWP
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return Response.json(
      { error: "Method not allowed" },
      { status: 405, headers: corsHeaders },
    );
  }

  const apiKey = Deno.env.get("BRIGHTDATA_API_KEY");
  if (!apiKey) {
    return Response.json(
      { error: "BRIGHTDATA_API_KEY is not configured" },
      { status: 500, headers: corsHeaders },
    );
  }

  let body: unknown;

  try {
    body = await req.json();
  } catch {
    return Response.json(
      { error: "Invalid JSON body" },
      { status: 400, headers: corsHeaders },
    );
  }

  const userName =
    typeof body === "object" &&
    body !== null &&
    "user_name" in body &&
    typeof (body as { user_name?: unknown }).user_name === "string"
      ? (body as { user_name: string }).user_name.trim()
      : "";

  if (!userName) {
    return Response.json(
      { error: "user_name is required" },
      { status: 400, headers: corsHeaders },
    );
  }

  if (!/^[a-zA-Z0-9._-]{1,100}$/.test(userName)) {
    return Response.json(
      { error: "Invalid user_name" },
      { status: 400, headers: corsHeaders },
    );
  }

  try {
    const response = await fetch(BRIGHTDATA_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        input: [{ user_name: userName }],
        limit_per_input: null,
      }),
    });

    const text = await response.text();

    let data: unknown;
    try {
      data = JSON.parse(text);
    } catch {
      data = { raw: text };
    }

    console.log(data);

    return Response.json(
      {
        ok: response.ok,
        status: response.status,
        data,
      },
      { status: response.ok ? 200 : response.status, headers: corsHeaders },
    );
  } catch (error) {
    console.error("Bright Data request failed:", error);

    return Response.json(
      { error: "Failed to query Bright Data" },
      { status: 502, headers: corsHeaders },
    );
  }
});
