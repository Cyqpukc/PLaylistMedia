public with sharing class CatalogMediaController {

	public String catalogId { get; set; }
	public String catalogName { get; set; }
	List<MediaWrapper> medias { get; set; }
	Set<Id> selectedMediaIds { get; set; }


	public CatalogMediaController() {
		catalogId = ApexPages.currentPage().getParameters().get('catalogId');
		if (String.isNotBlank(catalogId)) {
			List<scormanywhere__Catalog__c> catalogList = [SELECT Id, Name FROM scormanywhere__Catalog__c WHERE Id = :catalogId LIMIT 1];
			if (!catalogList.isEmpty()) {
				catalogName = catalogList.get(0).Name;
			}
		} else {
			catalogName = '';
		}
		medias = new List<MediaWrapper>();
		selectedMediaIds = new Set<Id>();
	}

	public ApexPages.StandardSetController con {
		get {
			if (con == null) {
				con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name FROM scormanywhere__Course__c]));
				con.setPageSize(20);
			}
			return con;
		}
		set;
	}

	private void updateSelectedMedias() {
		for (MediaWrapper mediaItem : medias) {
			if (mediaItem.isChecked) {
				selectedMediaIds.add(mediaItem.id);
			} else {
				selectedMediaIds.remove(mediaItem.id);
			}
		}
	}

	public List<MediaWrapper> getMedias() {
		updateSelectedMedias();

		medias = new List<MediaWrapper>();
		for (scormanywhere__Course__c media : (List<scormanywhere__Course__c>) con.getRecords()) {
			MediaWrapper mediaItem = new MediaWrapper(media);
			if (selectedMediaIds.contains(mediaItem.id)) {
				mediaItem.isChecked = true;
			}
			medias.add(mediaItem);
		}

		return medias;
	}

	public PageReference addToCatalog() {
		updateSelectedMedias();

		List<scormanywhere__Course_Catalog__c> mediaCatalogList = new List<scormanywhere__Course_Catalog__c>();
		for (Id mediaId : selectedMediaIds) {
			mediaCatalogList.add(new scormanywhere__Course_Catalog__c(
				scormanywhere__Catalog__c = catalogId,
				scormanywhere__Course__c = mediaId
			));
		}
		insert mediaCatalogList;

		return new PageReference('/' + catalogId);
	}

	public Boolean hasNext {
		get {
			return con.getHasNext();
		}
		set;
	}

	public Boolean hasPrevious {
		get {
			return con.getHasPrevious();
		}
		set;
	}

	public Integer pageNumber {
		get {
			return con.getPageNumber();
		}
		set;
	}

	public void first() {
		con.first();
	}

	public void last() {
		con.last();
	}

	public void previous() {
		con.previous();
	}

	public void next() {
		con.next();
	}

	public PageReference cancel() {
		return new PageReference('/' + (!String.isBlank(catalogId) ? catalogId : ''));
	}

	public class MediaWrapper {
		public Boolean isChecked { get; set; }
		public String name { get; set; }
		public String id { get; set; }

		public MediaWrapper(scormanywhere__Course__c media) {
			isChecked = false;
			name = media.name;
			id = media.id;
		}
	}

}