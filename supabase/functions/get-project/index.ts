// get-project: bir projeyi ve görevlerini tek istekte döndürür.
// POST /functions/v1/get-project   gövde: { "project_id": "..." }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const { project_id } = await req.json();
  if (!project_id) {
    return json({ error: "project_id gerekli" }, 400);
  }

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: project } = await admin
    .from("projects").select("*").eq("id", project_id).single();

  if (!project) {
    return json({ error: "Proje bulunamadı" }, 404);
  }

  const { data: tasks } = await admin
    .from("tasks").select("*").eq("project_id", project_id);

  return json({ project, tasks: tasks ?? [] });
});
