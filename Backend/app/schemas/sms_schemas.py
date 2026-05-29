from typing import Any, Dict, Optional

from pydantic import BaseModel


class SmsReceiveRequest(BaseModel):
    text: str


class SmsClassificationReport(BaseModel):
    text: str
    status: str
    category: str
    message: Optional[str] = None
    parsed_data: Optional[Dict[str, Any]] = None
    transaction_id: Optional[str] = None
