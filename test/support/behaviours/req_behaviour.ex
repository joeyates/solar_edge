defmodule ReqBehaviour do
  @callback get!(Req.url() | keyword() | Req.Request.t()) :: Req.Response.t()
end

