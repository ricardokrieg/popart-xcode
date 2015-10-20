$(function(){
	$('.bar a.mt').on('click', function(){
		$(this).siblings('ul').slideToggle();
	});
	//$('#datetimepicker1').datetimepicker();
	$('.general-flip').on('click', function(e){
		
		$('.general-content').slideToggle();
	});
});
