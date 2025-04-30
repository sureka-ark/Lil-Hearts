import { api, LightningElement } from "lwc";
const MESSAGE_CONTENT_CLASS = "embedded-messaging-message-content";
const ENDUSER = "EndUser";
const AGENT = "Agent";
const CHATBOT = "Chatbot";
const PARTICIPANT_TYPES = [ENDUSER, AGENT, CHATBOT];

export default class CustomChatComponent extends LightningElement {

  @api recordref = '';
  showButton = false;
  hideGraph = false;
  sendDocName = '';
  flowName = 'Upload_Pet_Image';

  get inputVariables()
  {
    return [
      {
        name: 'CaseOrMpFromLWCInput',
        type: 'String',
        value: this.recordref
      }
    ]
  }


  /**
   * Deployment configuration data.
   * @type {Object}
   */
  @api configuration;

  /**
   * Conversation entry data.
   * @type {Object}
   */
  @api conversationEntry;

  /**
   * Returns the sender of this conversation entry.
   * @returns {string}
   */
  get sender() {
    console.log(this.conversationEntry + ' ' + this.conversationEntry.sender.role);
    if (this.conversationEntry.sender.role == 'EndUser') {
      this.hideGraph = false;
    } else {
      this.hideGraph = true;
    }
    return this.conversationEntry.sender && this.conversationEntry.sender.role;
  }

  UploadfromFlow(event) {

    const url = 'https://in1740112455558.my.salesforce.com/flow/Upload_Pet_Image';

    navigator.clipboard.writeText(this.recordref)
      .then(() => {
        console.log(this.recordref);
      })
      .catch(error => {
        console.error(error);
      });

    // Open the popup window
    window.open(
      url,
      'FlowPopup',
      'width=800,height=600,resizable=yes,scrollbars=yes,status=yes'
    );

  }

  connectedCallback() {

  }

  /**
   * Returns the text content of the conversation entry.
   * @returns {string}
   */
  get textContent() {
    try {
      const entryPayload = JSON.parse(this.conversationEntry.entryPayload);
      console.log(entryPayload.abstractMessage);
      console.log(entryPayload.abstractMessage.staticContent);
      if (
        entryPayload.abstractMessage &&
        entryPayload.abstractMessage.staticContent
      ) {
        const text = entryPayload.abstractMessage.staticContent.text;
        if (text.toString().toLowerCase().includes('mp-') || (text.toString().toLowerCase().includes('case number: 0000') && !text.toString().toLowerCase().includes('update') && !text.toString().toLowerCase().includes('closed'))) {
          this.recordref = 'Something';
          if (text.toString().toLowerCase().includes('case number: 0000')) {
            let str = text.toString().toLowerCase();
            let index = str.indexOf("0000");
            let finalString = str.substring(index, index + 8);
            console.log(finalString)
            this.recordref = finalString;
          }
          else {
            let str = text.toString();
            let index = str.indexOf("MP-000");
            let finalString = str.substring(index, index + 8);
            console.log(finalString)
            this.recordref = finalString;
          }
          this.showButton = true;
          this.hideGraph = false;
          console.log(this.recordref);
        }
        else if (text.toString().toLowerCase().includes('past one week data of')) {
          // let index = text.toString().toLowerCase().lastIndexOf('doctor') + 7;
          // let len  = text.toString().length;
          // this.sendDocName = (text.toString().charAt(len-1)=='.')? text.toString().toLowerCase().substring(index, text.toString().length-1) : text.toString().toLowerCase().substring(index, text.toString().length);
          console.log(text.toString());
          if (text.toString().toLowerCase().includes('priya')) {
            this.sendDocName = "Priya";
          }
          if (text.toString().toLowerCase().includes('kishore')) {
            this.sendDocName = "Kishore";
          }
          if (text.toString().toLowerCase().includes('prashanth')) {
            this.sendDocName = "Prashanth";
          }
          if (text.toString().toLowerCase().includes('sai')) {
            this.sendDocName = "Sai";
          }

          console.log(this.sendDocName);
          this.hideGraph = true;

        }
        else {
          this.showButton = false;
          this.hideGraph = false;
          this.unhideMap = false;
        }
        return text;
        /*
         return text.replace(
           // innerText or textContent
           /(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?/g,
           function (imgUrl) {
             // Only switch out to specific shortened urls if the agent is the user.
             if (this.sender === AGENT) {
               // If the url is a specific link, then return a custom shortened link.
               if (
                 imgUrl === "https://shorturl.at/ohf0O" ||
                 imgUrl === "https://shorturl.at/ohf0O"
               ) {
                 return `<a target="_blank" href="${imgUrl}">Upload Image</a>`;
               }
               // Otherwise just shorten to a generic link "View Article".
               return `<a target="_blank" href="${imgUrl}">View Article</a>`;
             }
             return imgUrl;
           }.bind(this),
         ); 
         */
      }
      return "";
    } catch (e) {
      console.error(e);
    }
  }

  /**
   * Returns the class name of the message bubble.
   * @returns {string}
   */
  get generateMessageBubbleClassname() {
    if (this.isSupportedSender()) {
      return `${MESSAGE_CONTENT_CLASS} ${this.sender}`;
    } else {
      throw new Error(`Unsupported participant type passed in: ${this.sender}`);
    }
  }

  /**
   * True if the sender is a support participant type.
   * @returns {Boolean}
   */
  isSupportedSender() {
    return PARTICIPANT_TYPES.some(
      (participantType) => this.sender === participantType,
    );
  }

  handleStatusChange(event){
  console.log(event.detail.status); 
  }
}