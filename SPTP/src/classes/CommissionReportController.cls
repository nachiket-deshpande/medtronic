/**
 * Custom controller implementation that back "Commissions By Sales Rep" page. This class generates
 * data for monthly commissions by sales rep for the current year.
 * 
 * @author Max Rudman
 * @since 
 */
public with sharing class CommissionReportController {/*
	public static final List<String> MONTHS = new List<String>{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
	
	public Integer year {get; set;}
	private Date startDate;
	private Date endDate;
	public List<RepCommissions> commissions {get; private set;}
	
	// These are used by a separate page; this page is a debug page to verify profile account queries.
	public List<Account> activeAccounts {get; private set;}
	public Integer activeAccountCount { get{return (activeAccounts != null) ? activeAccounts.size() : 0;} }
	
	public CommissionReportController() {
		year = System.today().year();
	}
	
	public PageReference onGenerate() {
		//endDate = Date.newInstance(System.now().year(),System.now().month(),1).addMonths(1).addDays(-1);
		endDate = Date.newInstance(year, 12, 31);
		startDate = Date.newInstance(year, 1, 1);
		
		Set<Id> quotaIds = new Set<Id>();
		Map<String,Commission__c> commissionsByKey = new Map<String,Commission__c>();
		Map<Id,RepCommissions> rowsByRepId = new Map<Id,RepCommissions>();
		commissions = new List<RepCommissions>();
		Set<Id> addedRepIds = new Set<Id>();
		for (Commission__c commission : 
			[SELECT CommissionedSales__c, DisposableSales__c, WarrantySales__c, Period__c, 
			 	SalesRep__r.Id, SalesRep__r.LastName, SalesRep__r.FirstName, 
			 	SalesRep__r.Name, Quota__c, Key__c,
			 	Quota__r.Amount__c, Quota__r.Disposable_Amount__c
			 FROM Commission__c WHERE Period__c >= :startDate AND Period__c <= :endDate AND 
			 	SalesRep__r.UserRole.Name LIKE '%Region TM' AND Quota__c != null
			 ORDER BY SalesRep__r.LastName, SalesRep__r.FirstName, Period__c]) {
			RepCommissions row = rowsByRepId.get(commission.SalesRep__r.Id);
			if (row == null) {
				row = new RepCommissions(commission.SalesRep__r,year);
				rowsByRepId.put(commission.SalesRep__r.Id, row);
			}
			row.addCommission(commission);
			quotaIds.add(commission.Quota__c);
			commissionsByKey.put(commission.Key__c, commission);
			if (!addedRepIds.contains(row.salesRep.Id)) {
				commissions.add(row);
				addedRepIds.add(row.salesRep.Id);
			}
		}
		
		// Load and index monthly quotas
		//Map<Id,MonthlyQuota__c> quotasById = new Map<Id,MonthlyQuota__c>([SELECT Id, Amount__c, SalesRep__c FROM MonthlyQuota__c WHERE Id IN :quotaIds]);
		
		//reps = rowsByRepId.values();
		
		return null;
	}
	
	private Decimal ensureValue(Decimal value) {
		if (value == null) {
			return 0;
		}
		return value;
	}
	
	public List<String> getPeriodHeaders() {
		return MONTHS;
	}
	
	public RepCommissions getMyCommissions() {
		for (RepCommissions rc : commissions) {
			if (rc.salesRep.Id == UserInfo.getUserId()) {
				return rc;
			}
		}
		return null;
	}
	
	//Represents commissions for a single rep. Rendered as one row in the report table.

	public class RepCommissions {
		public User salesRep {get; private set;}
		public List<Period> periods {get; private set;}
		public Decimal quotaTotal {get; set;}
		public Decimal salesTotal {get; set;}
		private Integer year;
		
		public RepCommissions(User salesRep, Integer year) {
			this.salesRep = salesRep;
			this.year = year;
			this.periods = new Period[12];
			// for (Integer i=1;i<13;i++) {
			//	periods.add(new Period(this, new Commission__c(Period__c=Date.newInstance(year,i,1).addMonths(1).addDays(-1),CommissionedSales__c=0)));
			//} 
		}
		
		public void addCommission(Commission__c commission) {
			Integer cyear = commission.Period__c.year();
			Integer month = commission.Period__c.month();
			periods.set(month-1,new Period(this,commission));
		}
	}
	
	// Commissions for a given period (month).

	public class Period {
		private RepCommissions parent;
		private Decimal totalSalesYTD;
		private Decimal totalQuotaYTD;
		private Decimal totalSalesQTD;
		private Decimal disposableSalesQTD;
		private Decimal disposableQuotaQTD;
		
		public String name {get; private set;}
		public Commission__c commission {get; private set;}
		public MonthlyQuota__c quota {get; set;}
		
		public Decimal commissionsPaid {get; set;}
		
		public Boolean displayed {get{return isDisplayed();}}
		
		public Period(RepCommissions parent, Commission__c commission) {
			this.parent = parent;
			this.commission = commission;
			this.quota = commission.Quota__r;
			System.assert(quota != null, 'Com: ' + commission);
			name = CommissionReportController.MONTHS[commission.Period__c.month()-1];
			commissionsPaid = 0;
		}
		
		public Decimal getCatchUpAmount() {
			Decimal due = getTotalSalesYTD() * ((getTotalSalesYTD() >= getTotalQuotaYTD()) ? 0.1 : 0.08);
			if (isCatchUp() && (due > commissionsPaid)) {
				// Exclude current month standard commissions
				return due - commissionsPaid - getStandardAmount();
			}
			return 0;
		}
		
		public Decimal getStandardAmount() {
			Decimal amount = (commission.CommissionedSales__c * 0.08);
			if (commission.Period__c.month() <= 6) {
				return Math.max(6000, amount);
			}
			return amount;
		}
		
		public Decimal getTotalAmount() {
			return getStandardAmount() + getTotalBonusAmount() + getDisposableBonusAmount() + getCatchUpAmount();
		}
		
		public Decimal getTotalBonusAmount() {
			Decimal totalBonus = 0;
			if (isQuarterEnd()) {
				totalBonus = getTotalSalesQTD() * ((getTotalSalesYTD() >= getTotalQuotaYTD()) ? 0.02 : 0);
			}
			return totalBonus;
		}
		
		public Decimal getDisposableBonusAmount() {
			Decimal disposableBonus = 0;
			if (isQuarterEnd()) {
				disposableBonus = getTotalSalesQTD() * ((getDisposableSalesQTD() >= getDisposableQuotaQTD()) ? 0.02 : 0);
			}
			return disposableBonus;
		}
		
		public Boolean isCatchUp() {
			Integer month = commission.Period__c.month();
			return (month == 6) || (month == 12);
		}
		
		public Boolean isQuarterEnd() {
			return (Math.mod(commission.Period__c.month(), 3) == 0);
		}
		
		public Boolean isDisplayed() {
			Date cutoff = Date.newInstance(System.today().year(), System.today().month(),1).addMonths(1).addDays(-1);
			return (commission.Period__c > Date.newInstance(2009,8,1)) && (commission.Period__c <= cutoff);
		}
		
		public Decimal getTotalSalesYTD() {
			if (totalSalesYTD == null) {
				Integer month = commission.Period__c.month();
				totalSalesYTD = commission.CommissionedSales__c;
				if (month >= 2) {
					if (parent.periods[month-2] != null) {
						totalSalesYTD += parent.periods[month-2].getTotalSalesYTD();
					}
				}
			}
			return totalSalesYTD;
		}
		
		public Decimal getTotalQuotaYTD() {
			if (totalQuotaYTD == null) {
				totalQuotaYTD = 0;
				Integer month = commission.Period__c.month();
				totalQuotaYTD += quota.Amount__c;
				if (month >= 2) {
					if (parent.periods[month-2] != null) {
						totalQuotaYTD += parent.periods[month-2].getTotalQuotaYTD();
					}
				}
			}
			return totalQuotaYTD;
		}
		
		public Decimal getDisposableQuotaQTD() {
			if (disposableQuotaQTD == null) {
				disposableQuotaQTD = 0;
				Period[] periods = getPeriodsInSameQuarter();
				for (Period period : periods) {
					if ((period != null) && (period.quota != null) && (period.quota.Disposable_Amount__c != null)) {
						disposableQuotaQTD += period.quota.Disposable_Amount__c;
					}
				}
			}
			return disposableQuotaQTD;
		}
		
		public Decimal getDisposableSalesQTD() {
			if (disposableSalesQTD == null) {
				disposableSalesQTD = 0;
				Period[] periods = getPeriodsInSameQuarter();
				for (Period period : periods) {
					disposableSalesQTD += period.commission.DisposableSales__c;
				}
			}
			return disposableSalesQTD;
		}
		
		public Decimal getTotalSalesQTD() {
			if (totalSalesQTD == null) {
				totalSalesQTD = 0;
				Period[] periods = getPeriodsInSameQuarter();
				for (Period period : periods) {
					totalSalesQTD += period.commission.CommissionedSales__c;
				}
			}
			return totalSalesQTD;
		}
		
		public Period[] getPeriodsInSameQuarter() {
			List<Period> periods = new List<Period>();
			Integer month = commission.Period__c.month();
			Integer offset = Math.mod(month,3);
			for (Integer i=(month+(offset-3));i<(month+offset);i++) {
				if ((i >= 0) && (i < parent.periods.size()) && (parent.periods[i] != null)) {
					periods.add(parent.periods[i]);
				}
			}
			return periods;
		}
	}*/
}