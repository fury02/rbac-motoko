import React, {useState} from "react";
import {Alert, Button} from "react-bootstrap";

export function AlertDialog({text_alert}:any) {
    const [show, setShow] = useState(true);
    return (
        <>
            <div style={{ position: "fixed", top: 5, left: 500, right: 500, zIndex: 999 }}>
                <Alert show={show} variant="secondary" className="justify-content-center">
                    <Alert.Heading>Response:</Alert.Heading>
                    <p>
                        {text_alert}
                    </p>
                    <hr />
                    <div className="d-flex justify-content-center">
                        <Button onClick={() => setShow(false)} variant="info">
                            Close
                        </Button>
                    </div>
                </Alert>
            </div>
        </>
    );
}