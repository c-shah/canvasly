<script src="/js/canvas-all.js"></script>
<script src="/js/chatter-talk.js"></script>
<script src="/js/json2.js"></script>
<script src="/js/publisher.js"></script>

<div class="canvasContainer">
    signedRequest <textarea id="signedRequest" rows="5" cols="100"> ${escapedSignedRequest} </textarea> <br/><br/><hr/><br/>
    <input id="canvasPublishMessage" value=""/> <button onclick="canvasPublish( document.getElementById('canvasPublishMessage').value )" > Publish </button> <br/><br/><hr/><br/>
    Subcribed Message <br/> <br/>  <div id="canvasSubscribed"> &nbsp; </div> <br/><br/><hr/><br/>
    Subcribed Resize Event <br/> <br/>  <div id="canvasResizeSubscribed"> &nbsp; </div> <br/><br/><hr/><br/>
    Self Resize Servicve <button onclick="showCurrentSize()">Show Current Size</button> <br/> <br/>
    <input id="resizeWidthPx" value="" placeholder="width px"/> &nbsp; &nbsp; <input id="resizeHeightPx" value="" placeholder="height px"/> <button onclick="resizeMe( document.getElementById('resizeWidthPx').value, document.getElementById('resizeHeightPx').value )" > Resize Me </button> <br/><br/><hr/><br/>
    <button onclick="autogrow()"> autogrow </button> <br/><br/><hr/><br/>
    api call : get URL <input id="inputAPIURL" value=""/> <button onclick="apiCall( document.getElementById('inputAPIURL').value )" > API </button> <br/><br/><hr/><br/>
    chatter post <input id="chatterPostMessage" value=""/> <button onclick="postToChatter( document.getElementById('chatterPostMessage').value )" > Post </button> <br/><br/><hr/><br/>

</div>


<!-- init block -->
<script>
    var signedRequest = JSON.parse( '${signedRequest}' );

    Sfdc.canvas(function() {
        console.log( signedRequest );
        Sfdc.canvas.oauth.token(signedRequest.oauthToken);
        console.log( ' username ' + signedRequest.context.user.fullName );
    });
</script>

<!-- global var initialization block -->
<script>
    var namespacePrefix = '';   // e.g. test__
    var vfTopic = 'vfTopic';
    var canvasTopic = 'canvasTopic';
</script>


<!-- publish block -->
<script>
    function canvasPublish(message) {
        Sfdc.canvas.client.publish( signedRequest.client,{
            name :  namespacePrefix  + canvasTopic,
            payload : message
        });
        console.log(' canvas published : ' + message + ' to ' + canvasTopic );
    }
</script>

<!-- subscribe block -->
<script>
    Sfdc.canvas.client.subscribe(signedRequest.client, [{
        name: namespacePrefix  + vfTopic,
        onData: onData
    }]);

    function onData(message) {
        console.log(' canvas received message from visualforce ' + message.message );
        document.getElementById('canvasSubscribed').innerHTML = message.message;
    }
</script>


<!-- resize block -->
<script>
    function showCurrentSize() {
        var sizes = Sfdc.canvas.client.size();
        document.getElementById('resizeWidthPx').value = sizes.widths.pageWidth;
        document.getElementById('resizeHeightPx').value = sizes.heights.pageHeight;
    }

    Sfdc.canvas.client.subscribe(signedRequest.client, [{
        name: 'canvas.resize',          /** there is also, sfdc.streaming **/
        onData: onResizeData
    }]);

    function onResizeData(message) {
        console.log(' canvas received resize event ');
        console.log(message);
        document.getElementById('canvasResizeSubscribed').innerHTML = JSON.stringify(message);
    }

    function resizeMe(width, height) {
        console.log(' canvas is trying to resize it self to width ' + width + ' height ' + height );
        var dimension = Sfdc.canvas.client.size(signedRequest.client);
        Sfdc.canvas.client.resize(signedRequest.client, {height : height + "px", width : width + "px" } );
    }

    function autogrow() {
        console.log(' autogrow ');
        Sfdc.canvas.client.autogrow(signedRequest.client, true, 100);
    }
</script>

<!-- api block -->

<script>
    function apiCall(url) {
        console.log( ' api call ' + signedRequest.context.links.queryUrl );
        var url = signedRequest.context.links.queryUrl + "?q=SELECT+id+,+name+from+Account+Limit+10";
        console.log( ' url ' + url )
        var body = '';
        // var body = {body : {messageSegments : [{type: "Text", text: "Some Chatter Post"}]}};
        // data: JSON.stringify(body),
        Sfdc.canvas.client.ajax( url,
            {
                client : signedRequest.client,
                method: 'GET',
                contentType: "application/json",
                success : function(data) {
                    if (201 === data.status) {
                        alert("Success");
                    }
                }
            }
        );
    }
</script>

<!-- chatter block -->

<script>

    function postToChatter(message) {
        console.log(' posting to chatter ');
        chatterTalk.post(signedRequest, message, chatterPostCallback);
    }

    function chatterPostCallback(message) {
        console.log(' chatter post callback ' );
        console.log( message );
    }

</script>