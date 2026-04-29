from pydantic import BaseModel


class SmsReceiveRequest(BaseModel):
    text: str
