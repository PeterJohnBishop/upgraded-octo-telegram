import { Container, Col, Row, Button } from 'react-bootstrap'

function Home () {
    return (
        <Container fluid>
            <Row>
                <Col>
                <form method="POST" action="/profile-upload-single" enctype="multipart/form-data">
    <div>
        <label>Upload profile picture</label>
        <input type="file" name="profile-file" required/>
    </div>
    <div>
        <input type="submit" value="Upload" />
    </div>
</form>
                </Col>
                
            </Row>
        </Container>
    )
}

export default Home;