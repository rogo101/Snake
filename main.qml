import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Window {
    id: snakeWindow

    width: 640
    height: 480
    visible: true
    title: "Snake"
    color: "red"

    Rectangle {
        id: gameRect

        width: snakeWindow.width - snakeWindow.width % 20
        height: snakeWindow.height - snakeWindow.height % 20
        color: "lightgreen"
        anchors.centerIn: parent

        property int blockWidth: 20
        property int blockHeight: 20

        property int score: 0

        Rectangle {
            id: frontRectangle
            width: gameRect.blockWidth
            height: gameRect.blockHeight
            color: "purple"

            x: 0
            y: 0

            property string direction: "right"
            property alias score: gameRect.score

            Item {
                id: keyboardInputHandler
                anchors.fill: parent
                focus: true
                Keys.onLeftPressed: {
                    // backwards moves shouldn't be allowed
                    if (backwardsMove("left"))
                        return
                    updatePositionTimer.stop()
                    frontRectangle.changeDirection("left")
                    frontRectangle.nextMove()
                    updatePositionTimer.restart()
                }
                Keys.onRightPressed:{
                    if (backwardsMove("right"))
                        return
                    updatePositionTimer.stop()
                    frontRectangle.changeDirection("right")
                    frontRectangle.nextMove()
                    updatePositionTimer.restart()
                }
                Keys.onUpPressed: {
                    if (backwardsMove("up"))
                        return
                    updatePositionTimer.stop()
                    frontRectangle.changeDirection("up")
                    frontRectangle.nextMove()
                    updatePositionTimer.restart()
                }

                Keys.onDownPressed: {
                    if (backwardsMove("down"))
                        return
                    updatePositionTimer.stop()
                    frontRectangle.changeDirection("down")
                    frontRectangle.nextMove()
                    updatePositionTimer.restart()
                }

                function convertDirectionStringToInt(direction) {
                    switch (direction) {
                        case  "down":
                          return -2
                        case  "left":
                          return -1
                        case "right":
                          return 1
                        case    "up":
                          return 2
                    }
                    return 3 // base case should never get here
                }

                function backwardsMove(move) {
                    return (convertDirectionStringToInt(frontRectangle.direction) + convertDirectionStringToInt(move)) == 0
                }
            }

            function changeDirection(direction) {
                frontRectangle.direction = direction
            }

            function nextMove() {
                switch (direction) {
                    case "left":
                        moveLeft()
                        break
                    case "right":
                        moveRight()
                        break
                    case "up":
                        moveUp()
                        break
                    case "down":
                        moveDown()
                }
            }

            function moveLeft() {
                updatePosition()
                if (!collisionDetection()) {
                    snakeBody.updateRects(direction, x, y)
                    if (ateFood()) {
                        score += 1
                        updateLength()
                        foodRectangle.getNewPosition()
                    }
                }
                else {
                    snakeWindow.gameOver()
                }
            }

            function moveRight() {
                updatePosition()
                if (!collisionDetection()) {
                    snakeBody.updateRects(direction, x, y)
                    if (ateFood()) {
                        score += 1
                        updateLength()
                        foodRectangle.getNewPosition()
                    }
                }
                else {
                    snakeWindow.gameOver()
                }
            }

            function moveUp() {
                updatePosition()
                if (!collisionDetection()) {
                    snakeBody.updateRects(direction, x, y)
                    if (ateFood()) {
                        score += 1
                        updateLength()
                        foodRectangle.getNewPosition()
                    }
                }
                else {
                    snakeWindow.gameOver()
                }
            }

            function moveDown() {
                updatePosition()
                if (!collisionDetection()) {
                    snakeBody.updateRects(direction, x, y)
                    if (ateFood()) {
                        score += 1
                        updateLength()
                        foodRectangle.getNewPosition()
                    }
                }
                else {
                    snakeWindow.gameOver()
                }
            }

            function updatePosition() {
                switch (direction) {
                    case "left":
                        x -= gameRect.blockWidth
                        break
                    case "right":
                        x += gameRect.blockWidth
                        break
                    case "up":
                        y -= gameRect.blockHeight
                        break
                    case "down":
                        y += gameRect.blockHeight
                }
            }

            function collisionDetection() {
                if (x < 0 || x >= gameRect.width || y < 0 || y >= gameRect.height) {
                    return true
                }
                else if (snakeBody.ateItself(x, y)) {
                    return true
                }

                return false
            }

            function ateFood() {
                if (x === foodRectangle.x && y === foodRectangle.y) {
                    return true
                }
                return false
            }

            function updateLength() {
                snakeBody.addItem(direction, x, y)
            }

            function resetGame() {
                score = 0
                x = 0
                y = 0
                direction = "right"
                snakeBody.destroyBody()
                foodRectangle.getNewPosition()
                keyboardInputHandler.focus = true
                updatePositionTimer.restart()
            }

            Timer {
                id: updatePositionTimer
                interval: 125
                repeat: true
                onTriggered: {
                    frontRectangle.nextMove()
                }
            }

            Component.onCompleted: updatePositionTimer.start()
        }

        Repeater {
            id: snakeBody
            property int tailIndex: -1
            model: (gameRect.width * gameRect.height) / (gameRect.blockWidth * gameRect.blockHeight) - 1
            Rectangle {
                visible: false
                width: gameRect.blockWidth
                height: gameRect.blockHeight
                radius: 10
                color: "purple"
                property string direction
            }

            function ateItself(headX, headY) {
                if (tailIndex === -1) {
                    return false
                }
                for (let i = 0; i <= tailIndex; i++) {
                    if (headX === snakeBody.itemAt(i).x && headY === snakeBody.itemAt(i).y) {
                        return true
                    }
                }
                return false
            }

            function appendItem(direction, headX, headY) {
                let startX = headX
                let startY = headY
                switch (direction) {
                    case "left":
                        startX += gameRect.blockWidth
                        break
                    case "right":
                        startX -= gameRect.blockWidth
                        break
                    case "up":
                        startY += gameRect.blockHeight
                        break
                    case "down":
                        startY -= gameRect.blockHeight
                }
                tailIndex += 1
                snakeBody.itemAt(tailIndex).direction = direction
                snakeBody.itemAt(tailIndex).x = startX
                snakeBody.itemAt(tailIndex).y = startY
                snakeBody.itemAt(tailIndex).visible = true
                if(tailIndex == (snakeBody.count - 1)) {
                    snakeWindow.gameWon()
                }
            }

            function addItem(direction, headX, headY) {
                if (tailIndex === -1) {
                    appendItem(direction, headX, headY)
                }
                else {
                    direction = snakeBody.itemAt(tailIndex).direction
                    const prevX = snakeBody.itemAt(tailIndex).x
                    const prevY = snakeBody.itemAt(tailIndex).y
                    appendItem(direction, prevX, prevY)
                }
            }

            function updateRects(direction, headX, headY) {
                if (tailIndex === -1) {
                    return
                }
                if (tailIndex === 0) {
                    tailIndex -= 1
                    appendItem(direction, headX, headY)
                }
                else {
                    for (let i = tailIndex; i >= 1; i--) {
                        snakeBody.itemAt(i).direction = snakeBody.itemAt(i - 1).direction
                        snakeBody.itemAt(i).x = snakeBody.itemAt(i - 1).x
                        snakeBody.itemAt(i).y = snakeBody.itemAt(i - 1).y
                    }
                    let startX = headX
                    let startY = headY
                    switch (direction) {
                        case "left":
                            startX += gameRect.blockWidth
                            break
                        case "right":
                            startX -= gameRect.blockWidth
                            break
                        case "up":
                            startY += gameRect.blockHeight
                            break
                        case "down":
                            startY -= gameRect.blockHeight
                    }
                    snakeBody.itemAt(0).direction = direction
                    snakeBody.itemAt(0).x = startX
                    snakeBody.itemAt(0).y = startY
                }
            }

            function destroyBody() {
                tailIndex = -1
                for (let i = 0; i < count; i++) {
                    snakeBody.itemAt(i).visible = false
                }
            }
        }

        Rectangle {
            id: foodRectangle
            width: gameRect.blockWidth
            height: gameRect.blockHeight
            color: "blue"
            property int maxX: gameRect.width
            property int maxY: gameRect.height

            property int newX: 0
            property int newY: 0

            function getNewPosition() {
                randomlyPlaceFood()
                while (collisionWithSnake()) {
                    randomlyPlaceFood()
                }
                x = newX
                y = newY
            }

            function randomlyPlaceFood() {
                newX = Math.random() * maxX
                newX -= newX % 20
                newY = Math.random() * maxY
                newY -= newY % 20
            }

            function collisionWithSnake() {
                return snakeBody.ateItself(newX, newY)
            }

            Component.onCompleted: {
                getNewPosition()
            }
        }
    }

    Rectangle {
        id: scoreRectangle
        visible: false
        width: gameRect.width
        height: gameRect.height
        anchors.centerIn: parent

        ColumnLayout {
            anchors.centerIn: parent
            Text {
                color: "blue"
                text: "Score: " + gameRect.score
            }
            Button {
                text: "Restart?"
                onClicked: snakeWindow.restartGame()
            }
        }
    }

    property bool hasGameBeenWon

    function gameOver() {
        if (hasGameBeenWon) {
            return
        }

        gameRect.visible = false
        snakeWindow.title = "GAME OVER"
        scoreRectangle.visible = true
    }

    function gameWon() {
        hasGameBeenWon = true
        gameRect.visible = false
        snakeWindow.title = "YOU WON!!!"
        scoreRectangle.visible = true
    }

    function restartGame() {
        hasGameBeenWon = false
        scoreRectangle.visible = false
        snakeWindow.title = "Snake"
        gameRect.visible = true
        frontRectangle.resetGame()
    }
}
