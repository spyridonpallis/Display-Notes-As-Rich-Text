public with sharing class ContentNotesExtension {
    public String accountId { get; set; }
    public List<NoteWrapper> notes { get; set; }

    public ContentNotesExtension() {
        accountId = ApexPages.currentPage().getParameters().get('id');
        notes = new List<NoteWrapper>();

        // Use an ORDER BY clause to retrieve notes in descending order by CreatedDate
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :accountId ORDER BY SystemModstamp DESC LIMIT 200];

        for (ContentDocumentLink link : documentLinks) {
            ContentNote note = [SELECT Id, Title, Content, CreatedById, CreatedDate FROM ContentNote WHERE Id = :link.ContentDocumentId LIMIT 1];

            // Query the User object to get the user's name
            User createdByUser = [SELECT Id, Name FROM User WHERE Id = :note.CreatedById LIMIT 1];

            NoteWrapper noteWrapper = new NoteWrapper();
            noteWrapper.noteId = note.Id; // Add this line to set the noteId property
            noteWrapper.title = note.Title;
            noteWrapper.content = EncodingUtil.base64Decode(EncodingUtil.base64Encode(note.Content)).toString();
            noteWrapper.createdBy = createdByUser;
            noteWrapper.createdDate = note.CreatedDate;

            notes.add(noteWrapper);
        }
    }

    public class NoteWrapper {
        public String noteId { get; set; }
        public String title { get; set; }
        public String content { get; set; }
        public User createdBy { get; set; }
        public DateTime createdDate { get; set; }
    }
}
