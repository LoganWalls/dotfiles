"""This example uses the OpenAI API client to access local models running with LMStudio"""

from lsprotocol.types import (
    InlineCompletionItem,
    InlineCompletionOptions,
    InlineCompletionParams,
)
from openai import OpenAI
from result import Err, Ok, Result

from grimoire_ls import completion as cmp
from grimoire_ls.server import GrimoireServer


class MyGrimoire(GrimoireServer):
    pass


server = MyGrimoire()
# Note that the `api_key` is a dummy value (it is not required) for local models,
# the `base_url` points to your local server instead of the official OpenAI API.
oai_client = OpenAI(api_key="sk-blah", base_url="http://127.0.0.1:1234/v1")


@server.inline_completion(InlineCompletionOptions())
async def inline_completion(
    params: InlineCompletionParams,
) -> Result[list[InlineCompletionItem], str]:
    """Uses a fill-in-the-middle completion prompt to provide LLM-generated code completions."""

    before_cursor, after_cursor, _ = cmp.get_context(
        server, params, include_workspace_context=False
    )
    prompt = f"<|fim_prefix|>{before_cursor}<|fim_suffix|>{after_cursor}<|fim_middle|>"
    response = oai_client.completions.create(
        top_p=0.9,
        best_of=3,
        seed=1234,
        model="mlx-community/qwen2.5-coder-1.5b",
        prompt=prompt,
        temperature=0.1,
        max_tokens=200,
    )
    if not response.choices:
        return Err("Could not generate completions.")
    completion = response.choices[0].text

    return Ok(
        [
            InlineCompletionItem(insert_text=completion),
        ]
    )
